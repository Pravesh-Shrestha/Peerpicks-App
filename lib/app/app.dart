import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/home_screen.dart';
import 'package:peerpicks/features/onboarding/presentation/pages/onboarding_screen.dart';
// Ensure this path is correct

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Access the session service to check login status
    final sessionService = ref.watch(userSessionServiceProvider);
    final bool loggedIn = sessionService.isLoggedIn();

    return MaterialApp(
      title: 'PeerPicks',
      debugShowCheckedModeBanner: false,

      // 2. Theme Configuration
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),

      // 3. Conditional Navigation
      // If the user is already logged in, take them to Home.
      // Otherwise, start at the Onboarding/SignIn flow.
      home: loggedIn ? const HomeScreen() : const OnboardingScreen(),

      // You can also define named routes here if you prefer
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
