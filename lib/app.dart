import 'package:flutter/material.dart';
import 'package:peerpicks/screens/onboarding/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeerPicks',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {'/': (context) => const SplashScreen()},
    );
  }
}
