import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/services/hive/hive_service.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';
import 'package:peerpicks/features/auth/data/datasources/auth_datasource.dart';
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

class AuthLocalDataSource implements IAuthLocalDataSource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDataSource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    await _hiveService.register(user);
    return user;
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = _hiveService.login(email, password);

      if (user != null && user.authId != null) {
        // Pass the necessary fields to the session service
        await _userSessionService.saveUserSession(
          userId: user.authId!,
          email: user.email,
          fullName: user.fullName,
          // For local login, we pass a placeholder or the last known token
          token: 'OFFLINE_TOKEN',
          phone: user.phone,
          profilePicture: user.profilePicture,
        );
      }
      return user;
    } catch (e) {
      return null;
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

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      if (!_userSessionService.isLoggedIn()) {
        return null;
      }

      final userId = _userSessionService.getCurrentUserId();
      if (userId == null) {
        return null;
      }

      return _hiveService.getUserById(userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    try {
      return _hiveService.getUserByEmail(email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getUserById(String authId) async {
    try {
      return _hiveService.getUserById(authId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _userSessionService.clearSession();
      return true;
    } catch (e) {
      return false;
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
}
