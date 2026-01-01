import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/services/hive/hive_service.dart';
import 'package:peerpicks/features/auth/data/datasources/remote/auth_datasource.dart';
import 'package:peerpicks/features/auth/data/models/auth_hive_model.dart';

// Create provider
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthLocalDataSource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class AuthLocalDataSource implements IAuthDataSource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDataSource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<void> register(AuthHiveModel user) async {
    try {
      await _hiveService.register(user);
    } catch (e) {
      throw Exception("Registration failed: $e");
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = await _hiveService.login(email, password);
      if (user != null && user.authId != null) {
        // Save session so user stays logged in after app restart
        await _userSessionService.saveUserSession(
          userId: user.authId!,
          email: user.email,
          fullName: user.fullName,
          username: user.username,
          phoneNumber: user.phoneNumber,
          // Removed batchId
        );
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      // 1. Check if a session exists in SharedPreferences
      if (!_userSessionService.isLoggedIn()) {
        return null;
      }

      // 2. Get user ID from session
      final userId = _userSessionService.getCurrentUserId();
      if (userId == null) {
        return null;
      }

      // 3. Fetch full user details from Hive
      return await _hiveService.getUserById(userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      // Clear SharedPreferences session
      await _userSessionService.clearSession();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthHiveModel?> getUserById(String authId) async {
    try {
      return await _hiveService.getUserById(authId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    try {
      return await _hiveService.getUserByEmail(email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateUser(AuthHiveModel user) async {
    try {
      return await _hiveService.updateUser(user);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteUser(String authId) async {
    try {
      await _hiveService.deleteUser(authId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
