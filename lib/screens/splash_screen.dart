import 'package:flutter/material.dart';
import 'package:peerpicks/screens/auth/sign_in_screen.dart';
import 'dart:async'; // Required for Timer
// Assuming the path to your SignInScreen is correct

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start a 3-second timer
    Timer(const Duration(seconds: 3), () {
      // Navigate to the SignInScreen after 3 seconds
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Ensure the container takes up the whole screen
        width: double.infinity,
        height: double.infinity,
        color: Colors.white, // Match the light theme
        child: Image.asset(
          "assets/images/splash/peer_picks_splash.png", // The designated full-screen image path
          // **Mandatory: Use BoxFit.cover to fill the entire screen**
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
