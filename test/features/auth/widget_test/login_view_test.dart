import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peerpicks/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';

void main() {
  testWidgets('Login UI Interaction and Validation', (
    WidgetTester tester,
  ) async {
    // 1. Setup Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // 2. Override the provider with the mock instance
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        ],
        child: const MaterialApp(home: SignInScreen()),
      ),
    );

    // Wait for any microtasks (like getCurrentUser in your ViewModel) to finish
    await tester.pumpAndSettle();

    // Test 3: Find the Button
    final loginBtn = find.text('SIGN IN');
    expect(loginBtn, findsOneWidget);

    // Test 5: Trigger Validation
    await tester.tap(loginBtn);

    // pump() is enough to trigger the local form validation UI
    await tester.pump();

    // FIXED: Added the period to match your _validateEmail method return string
    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });
}
