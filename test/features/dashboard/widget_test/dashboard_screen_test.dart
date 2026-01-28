import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';

void main() {
  testWidgets('Dashboard Tabs and Search Icon', (tester) async {
    // 1. Setup Mock SharedPreferences (Since Dashboard watches AuthViewModel which uses it)
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    // Initial pump to load the widget tree
    await tester.pump();

    // --- Test 10: Search Icon presence ---
    // Your code: const Icon(Icons.search, color: Colors.black, size: 28)
    expect(find.byIcon(Icons.search), findsOneWidget);

    // --- Test Header Info ---
    // Verifies the "Welcome" text and default user name "Probs" exist
    expect(find.text("Welcome"), findsOneWidget);
    expect(find.text("Probs"), findsOneWidget);

    // --- Test 8: Tab Switching interaction ---

    // 1. Check if "Popular" tab content is visible by default
    // Your Popular tab has a header "Most Visited Places"
    expect(find.text("Most Visited Places"), findsOneWidget);

    // 2. Tap the "For You" Tab
    await tester.tap(find.text('For You'));

    // TabBarView requires pumpAndSettle to finish the sliding animation
    await tester.pumpAndSettle();

    // 3. Verify "For You" content is now visible
    // Your _buildReviewSkeleton method contains the text "Review Loading..."
    expect(find.text("Review Loading..."), findsWidgets);

    // 4. Verify "Popular" content is no longer visible (it's off-screen)
    expect(find.text("Most Visited Places"), findsNothing);
  });
}
