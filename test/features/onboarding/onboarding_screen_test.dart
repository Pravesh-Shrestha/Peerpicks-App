import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peerpicks/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:peerpicks/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:peerpicks/features/onboarding/data/models/onboarding_model.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';

void main() {
  late SharedPreferences sharedPrefs;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
  });
  Widget createOnboardingScreen() {
    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
      child: const MaterialApp(home: OnboardingScreen()),
    );
  }

  group('OnboardingScreen Widget Tests', () {
    testWidgets('WIDGET-Should display the first onboarding page on load', (
      tester,
    ) async {
      await tester.pumpWidget(createOnboardingScreen());
      expect(find.text(contents[0].title), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('WIDGET-Should change content when swiping to the next page', (
      tester,
    ) async {
      await tester.pumpWidget(createOnboardingScreen());

      // Swipe left on the PageView
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle(); // Wait for 300ms animation

      // Verify the second page title is now visible
      expect(find.text(contents[1].title), findsOneWidget);
    });

    testWidgets('WIDGET-Should navigate to SignInScreen when Skip is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createOnboardingScreen());

      final skipButton = find.text('Skip');
      await tester.tap(skipButton);

      // pumpAndSettle handles both the SnackBar and the Navigation transition
      await tester.pumpAndSettle();

      // Check if SignInScreen is the current page
      expect(find.byType(SignInScreen), findsOneWidget);
      // Verify SnackBar message from your code
      expect(
        find.text('Onboarding skipped. Proceeding to Sign In.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'WIDGET-Should navigate to SignInScreen after the last page button is pressed',
      (tester) async {
        await tester.pumpWidget(createOnboardingScreen());

        // 1. Navigate through all pages using the "Next" buttons
        for (int i = 0; i < contents.length - 1; i++) {
          final nextBtn = find.text(contents[i].buttonText);
          await tester.tap(nextBtn);
          await tester.pumpAndSettle();
        }

        // 2. On the last page, the "Skip" button should disappear (replaced by SizedBox in your code)
        expect(find.text('Skip'), findsNothing);

        // 3. Tap the final button (e.g., "Get Started")
        final finalBtn = find.text(contents.last.buttonText);
        await tester.tap(finalBtn);
        await tester.pumpAndSettle();

        // 4. Verify landing on SignInScreen
        expect(find.byType(SignInScreen), findsOneWidget);
      },
    );
  });
}
