import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peerpicks/features/profile/presentation/pages/profile_screen.dart';
import 'package:peerpicks/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';
import 'package:peerpicks/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:peerpicks/features/auth/presentation/state/auth_state.dart';
import 'package:peerpicks/core/widgets/logout_dialog.dart';

// Create a simple Mock for the AuthViewModel to control state
class MockAuthViewModel extends AuthViewModel {
  @override
  AuthState build() {
    return AuthState.initial().copyWith(status: AuthStatus.authenticated);
  }
}

void main() {
  late SharedPreferences sharedPrefs;

  setUp(() async {
    // 1. Correct SharedPreferences keys matching your UserSessionService
    SharedPreferences.setMockInitialValues({
      'user_full_name': 'John Doe',
      'user_email': 'john@example.com',
      'is_logged_in': true,
    });
    sharedPrefs = await SharedPreferences.getInstance();
  });

  Widget createProfileScreen() {
    return ProviderScope(
      overrides: [
        // 2. Override SharedPreferences
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),

        // 3. Override AuthViewModel to prevent redirect logic from firing
        authViewModelProvider.overrideWith(() => MockAuthViewModel()),
      ],
      child: MaterialApp(
        // Add routes so the Navigator knows what EditProfileScreen is
        home: const ProfileScreen(),
        routes: {
          '/edit-profile': (context) =>
              const Scaffold(body: Text('Edit Profile Page')),
        },
      ),
    );
  }

  group('ProfileScreen Widget Tests', () {
    testWidgets('Verify user data displays correctly from session', (
      tester,
    ) async {
      await tester.pumpWidget(createProfileScreen());

      // Allow Riverpod and SharedPreferences to settle
      await tester.pumpAndSettle();

      // Verify the UI rendered the mocked session data
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);

      // Verify Initial 'J' is derived correctly from 'John Doe'
      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('Verify Edit Profile navigation via Icon Button', (
      tester,
    ) async {
      await tester.pumpWidget(createProfileScreen());
      await tester.pumpAndSettle();

      // Find the specific icon used in your ProfileScreen code
      final editIcon = find.byIcon(Icons.edit_note);
      expect(editIcon, findsOneWidget);

      await tester.tap(editIcon);

      // Wait for navigation animation to finish
      await tester.pumpAndSettle();

      // Check for the screen type
      expect(find.byType(EditProfileScreen), findsOneWidget);
    });

    testWidgets('Logout button should trigger LogoutDialog', (tester) async {
      await tester.pumpWidget(createProfileScreen());
      await tester.pumpAndSettle();

      final logoutBtn = find.text('Logout');
      expect(logoutBtn, findsOneWidget);

      // Ensure button is in view (important for SingleChildScrollView)
      await tester.ensureVisible(logoutBtn);
      await tester.tap(logoutBtn);

      // Pump to show the dialog
      await tester.pumpAndSettle();

      // Verify the custom LogoutDialog widget is visible
      expect(find.byType(LogoutDialog), findsOneWidget);
    });
  });
}
