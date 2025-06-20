import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:taller_1_mv3/auth/Register_Screen.dart';
import 'package:taller_1_mv3/screens/EditarPerfilScreens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 1;
  String? nombreUsuario;
  String? urlImagenSubida;

  Future<void> obtenerNombreUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final snapshot = await FirebaseDatabase.instance.ref('usuarios/$uid').get();

      if (!mounted) return; // ✅ Evita el error de setState() después del dispose

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          nombreUsuario = data['nombre']?.toString() ?? 'Usuario';
          urlImagenSubida = data['foto']?.toString();
        });
      }
    }
  }

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
  void initState() {
    super.initState();
    obtenerNombreUsuario();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                radius: 55,
                backgroundImage: urlImagenSubida != null
                    ? NetworkImage(urlImagenSubida!)
                    : const AssetImage('assets/images/welcome.jpeg') as ImageProvider,
                backgroundColor: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              nombreUsuario ?? 'Usuario',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              user?.email ?? 'correo@desconocido.com',
              style: TextStyle(
                fontSize: 15,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.verified_user, color: theme.primaryColor),
                title: Text("Membresía", style: theme.textTheme.titleMedium),
                subtitle: Text("Premium - Activa", style: theme.textTheme.bodySmall),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.movie, color: theme.primaryColor),
                    title: Text("Historial de Películas", style: theme.textTheme.titleMedium),
                  ),
                  Divider(height: 1, color: theme.dividerColor),
                  ListTile(title: Text("• Origen", style: theme.textTheme.bodyMedium)),
                  ListTile(title: Text("• Interstellar", style: theme.textTheme.bodyMedium)),
                  ListTile(title: Text("• El Padrino", style: theme.textTheme.bodyMedium)),
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
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text("Editar Perfil", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
              icon: Icon(Icons.logout, color: theme.primaryColor),
              label: Text("Cerrar Sesión", style: TextStyle(color: theme.primaryColor)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.primaryColor),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: theme.primaryColor,
        onTap: _onBottomTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ],
      ),
    );
  }
}
