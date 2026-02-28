import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';

void main() {
  testWidgets('WIDGET-Dashboard Tabs and Search Icon', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.textContaining('Hello'), findsOneWidget);
    expect(find.text('Discover new places'), findsOneWidget);

    // 1. Verify "Popular" Tab is Visible by Default
    expect(find.text('Trending'), findsOneWidget);

    // 2. Tap the "For You" Tab
    await tester.tap(find.text('For You'));

    // TabBarView requires pumpAndSettle to finish the sliding animation
    await tester.pumpAndSettle();

    // 3. Verify "For You" content is now visible (ListView feed)
    expect(find.byType(ListView), findsWidgets);

    // 4. Verify "Popular" content is no longer visible (it's off-screen)
    expect(find.text('Trending'), findsNothing);
  });
}
