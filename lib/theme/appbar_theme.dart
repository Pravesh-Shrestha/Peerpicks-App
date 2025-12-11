import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    primarySwatch: Colors.blue,
    fontFamily: 'OpenSans Regular',
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.black,
      titleTextStyle: TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontFamily: 'OpenSans Bold',
      ),
    ),
  );
}
