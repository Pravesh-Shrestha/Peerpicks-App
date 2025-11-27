import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const PeerPicksApp());
}

class PeerPicksApp extends StatelessWidget {
  const PeerPicksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peer Picks',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Poppins'),
      home: const SplashScreen(),
    );
  }
}
