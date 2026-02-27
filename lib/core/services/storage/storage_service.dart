import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for the StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  // We read the instance that was overridden in main.dart
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs: prefs);
});

class StorageService {
  final SharedPreferences _prefs;

  StorageService({required SharedPreferences prefs}) : _prefs = prefs;

  // Generic Method for saving data
  // This helps if you ever want to add logging or encryption to all writes
  Future<bool> setData<T>(String key, T value) async {
    if (value is String) return await _prefs.setString(key, value);
    if (value is int) return await _prefs.setInt(key, value);
    if (value is bool) return await _prefs.setBool(key, value);
    if (value is double) return await _prefs.setDouble(key, value);
    if (value is List<String>) return await _prefs.setStringList(key, value);

    throw ArgumentError(
      'Type ${value.runtimeType} is not supported by SharedPreferences',
    );
  }

  // Getters with explicit types
  String? getString(String key) => _prefs.getString(key);
  int? getInt(String key) => _prefs.getInt(key);
  double? getDouble(String key) => _prefs.getDouble(key);
  bool? getBool(String key) => _prefs.getBool(key);
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  // Helper for "isFirstTime" or "isLoggedIn" checks
  bool getBoolOrDefault(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  // Remove & Clear
  // Protocol Compliance [2026-02-01]: Used for 'delete' operations on local data
  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();

  // Check if key exists
  bool containsKey(String key) => _prefs.containsKey(key);

  // Reload data from disk (useful if another process/service modifies prefs)
  Future<void> reload() => _prefs.reload();
}
