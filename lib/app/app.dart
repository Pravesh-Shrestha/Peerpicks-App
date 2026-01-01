import 'package:flutter/material.dart';
import 'package:peerpicks/features/splash/presentation/pages/splash_screen.dart';
import 'package:peerpicks/app/theme/theme_data.dart';

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
