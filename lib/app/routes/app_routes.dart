import 'package:flutter/material.dart';

/// Simple navigation utility class for PeerPicks
class AppRoutes {
  AppRoutes._();

  /// Standard Push
  static void push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  /// Replace current screen (Used for "Edit Profile" -> "Profile" perhaps)
  static void pushReplacement(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  /// Reset Navigation Stack (Used for Login success or Logout)
  static void pushAndRemoveUntil(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false, // This removes all previous screens
    );
  }

  /// Go back
  static void pop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Return to the very first screen (Dashboard root)
  static void popToFirst(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  /// Specific Logout Navigation
  /// Clears everything and sends user to the Sign In screen
  static void navigateToSignInAfterLogout(
    BuildContext context,
    Widget signInPage,
  ) {
    pushAndRemoveUntil(context, signInPage);
  }
}
