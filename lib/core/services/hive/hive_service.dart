import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../../features/auth/data/models/auth_hive_model.dart';

// Provider to access HiveService throughout the app
final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

class HiveService {
  static const String _userBoxName = 'userBox';
  static const String _sessionBoxName = 'sessionBox';

  // 1. Initialize Hive and Register Adapters
  Future<void> init() async {
    // Get the directory for storing the database
    var directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);

    // Register the AuthHiveModelAdapter (Generated from auth_hive_model.dart)
    // typeId must match the one used in @HiveType(typeId: 0)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  // 2. Register User (Save to userBox)
  Future<void> register(AuthHiveModel user) async {
    var box = await Hive.openBox<AuthHiveModel>(_userBoxName);
    await box.put(user.email, user); // Using email as the unique key
  }

  // 3. Login User & Create Session
  Future<AuthHiveModel?> login(String email, String password) async {
    var box = await Hive.openBox<AuthHiveModel>(_userBoxName);

    // Find user by email key
    var user = box.get(email);

    if (user != null && user.password == password) {
      // Save user to session box to persist login state
      var sessionBox = await Hive.openBox<AuthHiveModel>(_sessionBoxName);
      await sessionBox.put('current_user', user);
      return user;
    }
    return null; // Return null if credentials don't match
  }

  // 4. Check if Email Exists (Validation)
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    var box = await Hive.openBox<AuthHiveModel>(_userBoxName);
    return box.get(email);
  }

  // 5. Get Current Logged In User
  Future<AuthHiveModel?> getCurrentUser() async {
    var sessionBox = await Hive.openBox<AuthHiveModel>(_sessionBoxName);
    return sessionBox.get('current_user');
  }

  // 6. Logout (Clear Session)
  Future<void> logout() async {
    var sessionBox = await Hive.openBox<AuthHiveModel>(_sessionBoxName);
    await sessionBox.clear();
  }

  // 7. Clear All Data (For Testing)
  Future<void> deleteHive() async {
    await Hive.deleteBoxFromDisk(_userBoxName);
    await Hive.deleteBoxFromDisk(_sessionBoxName);
  }
}
