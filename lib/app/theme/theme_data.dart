import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'OpenSans Regular',

    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      // AppBar (green header)
      primary: Colors.lightGreen,
      onPrimary: Colors.white,

      // Accent color (purple FAB)
      secondary: Color(0xFF5E2EFF),
      onSecondary: Colors.white,

      // Bottom bar background + icons
      surface: Colors.white, // bottom bar background
      onSurface: Colors.black, // active icon color

      background: Colors.white,
      onBackground: Colors.black,

      error: Colors.red,
      onError: Colors.white,
    ),

    // AppBar styling
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.lightGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),

    // BottomAppBar styling
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: Colors.white,
      elevation: 8,
    ),

    // Floating Action Button styling
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 123, 255, 46), // purple
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),
  );
}
