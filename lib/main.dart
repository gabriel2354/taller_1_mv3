import 'package:flutter/material.dart';
import 'package:taller_1_mv3/screens/Home_Screen.dart';
import 'package:taller_1_mv3/screens/ProfileScreen.dart';
import 'package:taller_1_mv3/screens/SettingsScreen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';


void main() {
  runApp(MaterialApp(
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
  ));
}
