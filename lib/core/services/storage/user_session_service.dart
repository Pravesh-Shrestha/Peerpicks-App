import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences instance provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

// UserSessionService provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

class UserSessionService {
  final SharedPreferences _prefs;

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserProfilePicture = 'user_profile_picture';
  static const String _keyUserDob = 'user_dob';
  static const String _keyAuthToken = 'auth_token';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  // Save the full session (usually called during Login or Register)
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String fullName,
    required DateTime dob,
    required String token,
    String? phone,
    String? profilePicture,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserFullName, fullName);
    await _prefs.setString(_keyAuthToken, token);
    await _prefs.setString(_keyUserDob, dob.toIso8601String());
    if (phone != null) await _prefs.setString(_keyUserPhone, phone);
    if (profilePicture != null) {
      await _prefs.setString(_keyUserProfilePicture, profilePicture);
    }
  }

  // NEW: Update only profile details (called after Edit Profile success)
  Future<void> updateProfileDetails({
    required String fullName,
    required String dob, // Accepting string format from controller
    String? profilePicture,
  }) async {
    await _prefs.setString(_keyUserFullName, fullName);
    await _prefs.setString(_keyUserDob, dob);
    if (profilePicture != null) {
      // This will save the path returned by your backend (e.g., /uploads/image.png)
      await _prefs.setString(_keyUserProfilePicture, profilePicture);
    }
  }

  // Getters
  bool isLoggedIn() => _prefs.getBool(_keyIsLoggedIn) ?? false;
  String? getToken() => _prefs.getString(_keyAuthToken);
  String? getCurrentUserId() => _prefs.getString(_keyUserId);
  String? getCurrentUserEmail() => _prefs.getString(_keyUserEmail);
  String? getCurrentUserFullName() => _prefs.getString(_keyUserFullName);
  String? getCurrentUserPhone() => _prefs.getString(_keyUserPhone);

  DateTime? getCurrentUserDob() {
    final dobStr = _prefs.getString(_keyUserDob);
    if (dobStr == null) return null;
    try {
      return DateTime.parse(dobStr);
    } catch (e) {
      return null;
    }
  }

  String? getCurrentUserProfilePicture() =>
      _prefs.getString(_keyUserProfilePicture);

  Future<void> clearSession() async {
    await _prefs.clear();
  }
}
