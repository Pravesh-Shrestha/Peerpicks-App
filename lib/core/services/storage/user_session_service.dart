import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

final secureStorageProvider = Provider(
  (ref) => const FlutterSecureStorage(
    // EncryptedSharedPreferences is better for Android
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ),
);

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return UserSessionService(prefs: prefs, secureStorage: secureStorage);
});

class UserSessionService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  // Stream to allow the app to react to login/logout events automatically
  final _authStateController = StreamController<bool>.broadcast();
  Stream<bool> get authStateChanges => _authStateController.stream;

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserProfilePicture = 'user_profile_picture';
  static const String _keyUserDob = 'user_dob';
  static const String _tokenKey = 'auth_token';

  UserSessionService({
    required SharedPreferences prefs,
    required FlutterSecureStorage secureStorage,
  }) : _prefs = prefs,
       _secureStorage = secureStorage;

  /// Save full session (Used for AUTH: LOGIN, REGISTER)
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String fullName,
    required String token,
    dynamic dob,
    String? phone,
    String? profilePicture,
  }) async {
    // 1. Save sensitive data to SECURE storage
    await _secureStorage.write(key: _tokenKey, value: token);

    // 2. Save profile data to SharedPreferences
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserFullName, fullName);

    if (phone != null) await _prefs.setString(_keyUserPhone, phone);
    if (profilePicture != null) {
      await _prefs.setString(_keyUserProfilePicture, profilePicture);
    }

    if (dob != null) {
      final dobStr = dob is DateTime ? dob.toIso8601String() : dob.toString();
      await _prefs.setString(_keyUserDob, dobStr);
    }

    _authStateController.add(true);
  }

  /// Update existing profile (Used for USERS: UPDATEPROFILE)
  Future<void> updateProfileDetails({
    required String fullName,
    required String dob,
    String? profilePicture,
    String? phone,
  }) async {
    await _prefs.setString(_keyUserFullName, fullName);
    await _prefs.setString(_keyUserDob, dob);
    if (phone != null) await _prefs.setString(_keyUserPhone, phone);
    if (profilePicture != null) {
      await _prefs.setString(_keyUserProfilePicture, profilePicture);
    }
  }

  // Getters
  bool isLoggedIn() => _prefs.getBool(_keyIsLoggedIn) ?? false;

  Future<String?> getToken() async => await _secureStorage.read(key: _tokenKey);

  String? getCurrentUserId() => _prefs.getString(_keyUserId);
  String? getCurrentUserEmail() => _prefs.getString(_keyUserEmail);
  String? getCurrentUserFullName() => _prefs.getString(_keyUserFullName);
  String? getCurrentUserPhone() => _prefs.getString(_keyUserPhone);
  String? getCurrentUserProfilePicture() =>
      _prefs.getString(_keyUserProfilePicture);

  DateTime? getCurrentUserDob() {
    final dobStr = _prefs.getString(_keyUserDob);
    if (dobStr == null) return null;
    return DateTime.tryParse(dobStr);
  }

  /// Delete session (Protocol Compliance: Clear all storage)
  /// Replaces "purge" or "clear" to align with project standards.
  Future<void> clearSession() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
    _authStateController.add(false);
  }

  void dispose() {
    _authStateController.close();
  }
}
