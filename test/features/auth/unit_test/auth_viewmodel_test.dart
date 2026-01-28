import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth Unit Tests', () {
    // Test 1: URL Sanitization (Matches your logic in dashboard_screen.dart)
    test('API URL should remove double slashes correctly', () {
      const String baseUrl = "http://10.0.2.2:3000//";
      final sanitized = baseUrl.replaceAll(RegExp(r'(?<!:)/+'), '/');
      expect(sanitized, "http://10.0.2.2:3000/");
    });

    // Test 2: Name Splitting
    test('Should extract first name for the dashboard greeting', () {
      const String fullName = "Probs";
      final String firstName = fullName.split(' ')[0];
      expect(firstName, "Probs");
    });
  });
}
