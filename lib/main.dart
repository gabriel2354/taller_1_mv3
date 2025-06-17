import 'package:flutter/material.dart';
import 'package:taller_1_mv3/screens/Home_Screen.dart';
import 'package:taller_1_mv3/screens/ProfileScreen.dart';
import 'package:taller_1_mv3/screens/SettingsScreen.dart';
import 'screens/welcome_screen.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    ),
  );
}
