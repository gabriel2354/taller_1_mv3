import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _celularController = TextEditingController();
  final _correoController = TextEditingController();

  final _passwordReauthController = TextEditingController();
  final _nuevoCorreoController = TextEditingController();
  final _nuevaContrasenaController = TextEditingController();

  final uid = FirebaseAuth.instance.currentUser!.uid;
  final currentUser = FirebaseAuth.instance.currentUser!;

  bool mostrarCambiarCorreo = false;
  bool mostrarCambiarContrasena = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
    _correoController.text = currentUser.email ?? '';
  }

  void cargarDatos() async {
    final ref = FirebaseDatabase.instance.ref("usuarios/$uid");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      print('Datos cargados: $data'); // Para depuración en consola
      setState(() {
        _nombreController.text = data['nombre'] ?? '';
        _edadController.text = data['edad'] ?? '';
        _celularController.text = data['celular'] ?? '';
      });
    }
  }

  Future<void> guardarCambios() async {
    final ref = FirebaseDatabase.instance.ref("usuarios/$uid");
    await ref.update({
      "nombre": _nombreController.text,
      "edad": _edadController.text,
      "celular": _celularController.text,
      "correo": _correoController.text,
    });

    mostrarMensaje("Perfil actualizado correctamente");
  }

  Future<void> reautenticar(String password) async {
    try {
      final cred = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: password,
      );
      await currentUser.reauthenticateWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      throw Exception("Error de reautenticación: ${e.message}");
    }
  }

  Future<void> cambiarCorreo() async {
    if (_nuevoCorreoController.text.isEmpty || _passwordReauthController.text.isEmpty) {
      mostrarMensaje("Por favor ingresa tu contraseña actual y el nuevo correo.");
      return;
    }

    try {
      await reautenticar(_passwordReauthController.text);
      await currentUser.updateEmail(_nuevoCorreoController.text.trim());
      _correoController.text = _nuevoCorreoController.text.trim();

      // Actualiza también en Realtime Database para mantener datos sincronizados
      final ref = FirebaseDatabase.instance.ref("usuarios/$uid");
      await ref.update({"correo": _correoController.text});

      mostrarMensaje("Correo actualizado correctamente.");
      _nuevoCorreoController.clear();
      _passwordReauthController.clear();
      setState(() {
        mostrarCambiarCorreo = false;
      });
    } on FirebaseAuthException catch (e) {
      mostrarMensaje("Error al actualizar correo: ${e.message}");
    } catch (e) {
      mostrarMensaje("Error inesperado: $e");
    }
  }

  Future<void> cambiarContrasena() async {
    if (_nuevaContrasenaController.text.isEmpty || _passwordReauthController.text.isEmpty) {
      mostrarMensaje("Por favor ingresa tu contraseña actual y la nueva contraseña.");
      return;
    }

    try {
      await reautenticar(_passwordReauthController.text);
      await currentUser.updatePassword(_nuevaContrasenaController.text.trim());
      mostrarMensaje("Contraseña actualizada correctamente.");
      _nuevaContrasenaController.clear();
      _passwordReauthController.clear();
      setState(() {
        mostrarCambiarContrasena = false;
      });
    } on FirebaseAuthException catch (e) {
      mostrarMensaje("Error al actualizar contraseña: ${e.message}");
    }
  }

  Future<void> eliminarCuenta() async {
    bool confirmar = await mostrarConfirmacion("¿Estás seguro de eliminar tu cuenta? Esta acción no se puede deshacer.");
    if (!confirmar) return;

    try {
      await currentUser.delete();
      mostrarMensaje("Cuenta eliminada correctamente.");
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      mostrarMensaje("Error al eliminar cuenta: ${e.message}");
    }
  }

  Future<void> mostrarMensaje(String mensaje) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Aviso"),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  Future<bool> mostrarConfirmacion(String mensaje) async {
    bool resultado = false;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar"),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () {
              resultado = false;
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text("Aceptar"),
            onPressed: () {
              resultado = true;
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
    return resultado;
  }

  // Función para resetear el nombre a un valor fijo para probar
  Future<void> resetearNombreDePrueba() async {
    final ref = FirebaseDatabase.instance.ref("usuarios/$uid");
    await ref.update({"nombre": "Nombre de prueba"});
    setState(() {
      _nombreController.text = "Nombre de prueba";
    });
    mostrarMensaje("Nombre reseteado a 'Nombre de prueba' para prueba.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Perfil"), backgroundColor: Colors.deepPurple),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Datos básicos
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _edadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Edad"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _celularController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Celular"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _correoController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: "Correo actual",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Botón para resetear el nombre a prueba
            ElevatedButton(
              onPressed: resetearNombreDePrueba,
              child: const Text("Resetear nombre a prueba"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 40),
              ),
            ),

            const SizedBox(height: 24),

            // Botón para mostrar cambiar correo
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => mostrarCambiarCorreo = !mostrarCambiarCorreo),
                child: Text(
                  mostrarCambiarCorreo ? "Cancelar cambio de correo" : "Cambiar correo",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),

            Visibility(
              visible: mostrarCambiarCorreo,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nuevoCorreoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Nuevo correo"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordReauthController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Contraseña actual"),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: cambiarCorreo,
                    child: const Text("Guardar correo"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 36),
                      backgroundColor: Colors.blueGrey,
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Botón para mostrar cambiar contraseña
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => mostrarCambiarContrasena = !mostrarCambiarContrasena),
                child: Text(
                  mostrarCambiarContrasena ? "Cancelar cambio de contraseña" : "Cambiar contraseña",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),

            Visibility(
              visible: mostrarCambiarContrasena,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nuevaContrasenaController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Nueva contraseña"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordReauthController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Contraseña actual"),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: cambiarContrasena,
                    child: const Text("Guardar contraseña"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(140, 36),
                      backgroundColor: Colors.blueGrey,
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            const Divider(height: 32),

            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Guardar datos"),
              onPressed: guardarCambios,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever),
              label: const Text("Eliminar cuenta"),
              onPressed: eliminarCuenta,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
