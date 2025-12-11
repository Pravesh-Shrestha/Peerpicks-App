import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          fontFamily: 'OpenSans Reg',
        ),
        backgroundColor: Colors.lightGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    ),
  );
}
