import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.lightGreen,
      unselectedItemColor: Colors.white,
    ),
  );
}
