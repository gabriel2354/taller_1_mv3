import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taller_1_mv3/auth/login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _nombre = TextEditingController();
    final _correo = TextEditingController();
    final _contrasenia = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarse'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Crea tu cuenta ',
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed:
              () => registrarse(_correo.text, _contrasenia.text, context),
          child: Text("Registro"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> registrarse(String correo, String contrasenia, BuildContext context) async {
  // Validar campos vacíos
  if (correo.isEmpty || contrasenia.isEmpty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Campos vacíos'),
        content: const Text('Por favor, llena todos los campos para registrarte.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return; // Salir sin continuar el registro
  }

  try {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: correo, password: contrasenia);

    // Si se registra con éxito, mostrar mensaje de éxito
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Registro exitoso!'),
        content: Text('Gracias por registrarte, ${credential.user?.email ?? 'usuario'}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar el diálogo
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error de registro'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  } catch (e) {
    print(e); // Para debug
  }
}
