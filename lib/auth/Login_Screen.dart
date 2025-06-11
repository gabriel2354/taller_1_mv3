import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taller_1_mv3/screens/Home_Screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              'Bienvenido de nuevo 🎥',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
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
                  backgroundColor: Colors.deepPurpleAccent,
                ),
                onPressed: () {
                  // Solo llama la función, sin navegar aquí
                    loginFire(
                    emailController.text,
                    passwordController.text,
                    context,
                  );
                },
                child: const Text('Ingresar'),
              ),
            ),

            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> loginFire(String correo, String contrasenia, BuildContext context) async {
  // Validar si los campos están vacíos
  if (correo.isEmpty || contrasenia.isEmpty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Campos incompletos'),
        content: const Text('Por favor, completa todos los campos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: correo,
      password: contrasenia,
    );

    final user = credential.user;

    if (user != null) {
      // Mostrar mensaje de bienvenida
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¡Bienvenido!'),
          content: Text('Hola, ${user.email ?? 'usuario'}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
    }

  } on FirebaseAuthException catch (e) {
    String mensaje = '';
    if (e.code == 'user-not-found') {
      mensaje = 'No se encontró un usuario con ese correo.';
    } else if (e.code == 'wrong-password') {
      mensaje = 'La contraseña es incorrecta.';
    } else {
      mensaje = 'Error al iniciar sesión: ${e.message}';
    }

    // Mostrar mensaje de error
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
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
}
