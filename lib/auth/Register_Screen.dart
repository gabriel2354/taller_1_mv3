import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_1_mv3/auth/login_screen.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _contrasenia = TextEditingController();
  final TextEditingController _edad = TextEditingController();
  final TextEditingController _celular = TextEditingController();
  String? urlImagenSubida;

  XFile? imagen;
  void cambiarImagen(XFile nuevaImagen) {
    setState(() {
      imagen = nuevaImagen;
    });
  }

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _contrasenia.dispose();
    _edad.dispose();
    _celular.dispose();
    super.dispose();
  }

  Future<void> registrarse() async {
    String nombre = _nombre.text.trim();
    String correo = _correo.text.trim();
    String contrasenia = _contrasenia.text.trim();
    String edad = _edad.text.trim();
    String celular = _celular.text.trim();

    if (nombre.isEmpty ||
        correo.isEmpty ||
        contrasenia.isEmpty ||
        edad.isEmpty ||
        celular.isEmpty) {
      _mostrarDialogo('Campos vacíos', 'Por favor, completa todos los campos.');
      return;
    }

    if (int.tryParse(edad) == null || int.parse(edad) < 10) {
      _mostrarDialogo(
        'Edad inválida',
        'Ingresa una edad válida (mayor de 10 años).',
      );
      return;
    }

    if (!RegExp(r'^[0-9]{7,15}$').hasMatch(celular)) {
      _mostrarDialogo(
        'Número inválido',
        'Ingresa un número de celular válido.',
      );
      return;
    }

    try {
      // 1. Subir imagen si hay
      if (imagen != null) {
        final url = await subirImagen(imagen!);
        if (url == null) {
          _mostrarDialogo(
            "Error",
            "No se pudo subir la imagen. Intenta de nuevo.",
          );
          return;
        } else {
          urlImagenSubida = url;
        }
      }

      // 2. Crear usuario en Firebase Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: correo, password: contrasenia);

      final uid = credential.user!.uid;
      final dbRef = FirebaseDatabase.instance.ref();
      await dbRef.child('usuarios/$uid').set({
        'nombre': nombre,
        'correo': correo,
        'edad': edad,
        'celular': celular,
        'foto': urlImagenSubida,
      });

      // 3. Éxito
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¡Registro exitoso!'),
          content: Text('Gracias por registrarte, $correo'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      String mensaje = '';
      if (e.code == 'weak-password') {
        mensaje = 'La contraseña es demasiado débil.';
      } else if (e.code == 'email-already-in-use') {
        mensaje = 'Ya existe una cuenta con ese correo.';
      } else {
        mensaje = 'Ocurrió un error: ${e.message}';
      }
      _mostrarDialogo('Error de registro', mensaje);
    } catch (e) {
      _mostrarDialogo('Error', 'Ocurrió un error inesperado: $e');
    }
  }

  void _mostrarDialogo(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarse'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Crea tu cuenta',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nombre,
              decoration: const InputDecoration(
                labelText: 'Nombre de usuario',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _celular,
              decoration: const InputDecoration(
                labelText: 'Celular',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _edad,
              decoration: const InputDecoration(
                labelText: 'Edad',
                prefixIcon: Icon(Icons.cake),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _correo,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contrasenia,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(thickness: 2),
            const SizedBox(height: 16),
            const Text(
              "Selecciona una imagen",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () => abrirGaleria(cambiarImagen),
                  label: const Text("Galería"),
                  icon: const Icon(Icons.landscape_sharp),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => abrirCamara(cambiarImagen),
                  label: const Text("Cámara"),
                  icon: const Icon(Icons.camera),
                ),
              ],
            ),
            const SizedBox(height: 16),
            imagen == null
                ? const Text("No hay imagen seleccionada")
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(imagen!.path),
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: registrarse,
                child: const Text("Registrarse"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> abrirGaleria(Function _cambiarImagen) async {
  final imganSelecionada = await ImagePicker().pickImage(
    source: ImageSource.gallery,
  );
  if (imganSelecionada != null) {
    _cambiarImagen(imganSelecionada);
  }
}

Future<void> abrirCamara(Function _cambiarImagen) async {
  final imagenSeleccionada = await ImagePicker().pickImage(
    source: ImageSource.camera,
  );
  if (imagenSeleccionada != null) {
    _cambiarImagen(imagenSeleccionada);
  }
}

Future<String?> subirImagen(XFile imagen) async {
  try {
    final supabase = Supabase.instance.client;
    final fileExt = p.extension(imagen.path);
    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}$fileExt';
    final filePath = 'public/$fileName';

    // ✅ Leer imagen como bytes (compatible con móvil y web)
    final bytes = await imagen.readAsBytes();

    // ✅ Subir con uploadBinary
    await supabase.storage
        .from('usuario')
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    final publicUrl = supabase.storage.from('usuario').getPublicUrl(filePath);
    print('✅ Imagen subida: $publicUrl');
    return publicUrl;
  } catch (e) {
    print('❌ Error al subir imagen: $e');
    return null;
  }
}
