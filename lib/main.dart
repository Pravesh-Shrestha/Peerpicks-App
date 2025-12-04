import 'package:flutter/material.dart';
import 'package:peerpicks/screens/splash_screen.dart';// Import the initial splash screen

void main() {
  // Ensure the widget binding is initialized before using assets
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const SplashScreen());
  }
}
