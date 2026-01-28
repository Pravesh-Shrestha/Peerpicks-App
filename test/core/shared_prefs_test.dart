import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Core: Shared Preferences should store auth token', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', 'abc_123');
    expect(prefs.getString('token'), 'abc_123');
  });
}
