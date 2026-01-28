import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this
import 'package:peerpicks/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:peerpicks/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart'; // Import your provider

void main() {
  testWidgets('WIDGET-Tapping Skip on Onboarding navigates to SignInScreen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    // Find and tap the Skip button
    final skipButton = find.text('Skip');
    expect(skipButton, findsOneWidget);

    await tester.tap(skipButton);
    await tester.pumpAndSettle();

    // Verify we are now on the SignInScreen
    expect(find.byType(SignInScreen), findsOneWidget);
  });
}
