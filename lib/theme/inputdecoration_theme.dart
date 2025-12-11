import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: const OutlineInputBorder(),
      labelStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontFamily: 'OpenSans Regular',
      ),
    ),
  );
}
