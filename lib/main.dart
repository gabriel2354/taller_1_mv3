import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  await Supabase.initialize(
    url: 'https://kgudsdateszjxkgcvhnv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtndWRzZGF0ZXN6anhrZ2N2aG52Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2ODQ0NzksImV4cCI6MjA2NTI2MDQ3OX0.z3HoewlQUCQkEUDEXPvU9KUq14SKjO6dYItMnIy2vM8',
  );
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
