import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:peerpicks/core/constants/hive_table_constant.dart';
import 'package:peerpicks/features/auth/data/models/auth_hive_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  // Initialize Hive
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);

    // Register adapter
    _registerAdapter();
    await _openBoxes();
  }

  void _registerAdapter() {
    // Note: If you changed field indexes in AuthHiveModel,
    // you must increment the TypeId or delete the app/box.
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  // Box management
  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
  }

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  // ======================= Auth Queries =========================

  Future<void> register(AuthHiveModel user) async {
    // user.authId is the key, ensuring no duplicates for the same ID
    await _authBox.put(user.authId, user);
  }

  AuthHiveModel? login(String email, String password) {
    try {
      // Local login check against encrypted/hashed or plain passwords stored in Hive
      return _authBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  AuthHiveModel? getUserById(String authId) {
    return _authBox.get(authId);
  }

  bool isEmailRegistered(String email) {
    return _authBox.values.any((user) => user.email == email);
  }

  Future<AuthHiveModel?> getUserByEmail(String email) async {
    try {
      return _authBox.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateUser(AuthHiveModel user) async {
    if (_authBox.containsKey(user.authId)) {
      await _authBox.put(user.authId, user);
      return true;
    }
    return false;
  }

  Future<void> deleteUser(String authId) async {
    await _authBox.delete(authId);
  }

  // Clear all auth data (useful for testing or total reset)
  Future<void> clearAll() async {
    await _authBox.clear();
  }
}
