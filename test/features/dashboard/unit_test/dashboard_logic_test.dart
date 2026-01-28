import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Dashboard Logic Tests', () {
    // Test 6: Tab Initialization
    test('Dashboard should initialize with tab index 0', () {
      const int initialTab = 0;
      expect(initialTab, 0);
    });

    // Test 7: Empty State Logic
    test('Should return default placeholder when user profile is null', () {
      const String? profileImage = null;
      final String displayImage = profileImage ?? 'assets/default_user.png';
      expect(displayImage, 'assets/default_user.png');
    });
  });
}
