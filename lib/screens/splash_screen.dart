// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
// import 'onboarding/onboarding_screen.dart'; // Change to SignInScreen if needed

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();

//     Future.delayed(const Duration(seconds: 3), () {
//       if (!mounted) return;
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const OnboardingScreen()),
//       );
//     });
//   }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(
      0xFF92E348,
    ), // fallback color in case image fails
    body: Stack(
      children: [
        // Full-screen background image using Image.asset
        Positioned.fill(
          child: Image.asset(
            'assets/images/splash/peer_picks_splash.png', // Your exact splash image
            fit: BoxFit.cover, // Makes it fill the entire screen beautifully
          ),
        ),

        // Optional: Add a subtle overlay or logo on top if needed
        // Example (remove if your image already has everything):
        /*
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "PEER\nPICKS",
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  "@peer_picks",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          */
      ],
    ),
  );
}
