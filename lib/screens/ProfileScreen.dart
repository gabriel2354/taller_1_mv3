import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taller_1_mv3/screens/EditarPerfilScreens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 1;

  void _onBottomTap(int index) {
    if (_currentIndex == index) return;

    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : const AssetImage('assets/images/welcome.jpeg')
                          as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'Usuario',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'correo@desconocido.com',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: ListTile(
                leading: const Icon(
                  Icons.verified_user,
                  color: Colors.deepPurple,
                ),
                title: const Text("Membresía"),
                subtitle: const Text("Premium - Activa"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.movie, color: Colors.deepPurple),
                    title: Text("Historial de Películas"),
                  ),
                  Divider(height: 1),
                  ListTile(title: Text("• Origen")),
                  ListTile(title: Text("• Interstellar")),
                  ListTile(title: Text("• El Padrino")),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditarPerfil()),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text("Editar Perfil"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 209, 206, 214),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
              icon: const Icon(Icons.logout),
              label: const Text("Cerrar Sesión"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onBottomTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}
