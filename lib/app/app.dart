import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/app/theme/app_theme_provider.dart';
import 'package:peerpicks/app/theme/app_themes.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/home_screen.dart';
import 'package:peerpicks/features/onboarding/presentation/pages/onboarding_screen.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Access the session service to check login status
    final sessionService = ref.watch(userSessionServiceProvider);
    final bool loggedIn = sessionService.isLoggedIn();

    // 2. Watch the theme provider for live palette + mode switching
    final themeState = ref.watch(appThemeProvider);

    return MaterialApp(
      title: 'PeerPicks',
      debugShowCheckedModeBanner: false,

      // 3. Theme Configuration — driven by provider
      theme: AppThemes.lightTheme(themeState.palette),
      darkTheme: AppThemes.darkTheme(themeState.palette),
      themeMode: themeState.mode,

      // 4. Conditional Navigation
      home: loggedIn ? const HomeScreen() : const OnboardingScreen(),

      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
