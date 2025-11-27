import 'package:flutter/material.dart';
import 'package:peerpicks/screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/home/home_shell.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeerPicks',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeShell(), // bottom nav shell
      },
    );
  }
}
