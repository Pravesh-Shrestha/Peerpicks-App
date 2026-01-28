import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this
import 'package:peerpicks/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:peerpicks/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart'; // Import your provider

void main() {
  testWidgets('Tapping Skip on Onboarding navigates to SignInScreen', (
    WidgetTester tester,
  ) async {
    // 1. Setup Mock SharedPreferences (matches your main.dart logic)
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // 2. You MUST override the sharedPreferencesProvider in tests
          // because your SignInScreen depends on it indirectly.
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        ],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    // Find and tap the Skip button
    final skipButton = find.text('Skip');
    expect(skipButton, findsOneWidget);

    await tester.tap(skipButton);

    // 3. pumpAndSettle waits for the Navigator animation AND
    // any internal state initialization in SignInScreen.
    await tester.pumpAndSettle();

    // Verify we are now on the SignInScreen
    expect(find.byType(SignInScreen), findsOneWidget);
  });
}
