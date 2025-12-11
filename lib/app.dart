import 'package:flutter/material.dart';
import 'package:peerpicks/screens/onboarding/splash_screen.dart';
import 'package:peerpicks/theme/appbar_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeerPicks',
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      initialRoute: '/',
      routes: {'/': (context) => const SplashScreen()},
    );
  }
}
