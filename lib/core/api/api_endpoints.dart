import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = false;

  static const String compIpAddress = "192.168.0.1";

  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:3000/api/v1';
    }
    // yadi android
    if (kIsWeb) {
      return 'http://localhost:3000/api/';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/';
    } else if (Platform.isIOS) {
      return 'http://localhost:3000/api/';
    } else {
      return 'http://localhost:3000/api/';
    }
  }


  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Auth Endpoints ============
  // Since you used app.use('/api/auth', authRoutes) in Express:

  static const String login = 'auth/login'; // Becomes: .../api/auth/login
  static const String register =
      'auth/register'; // Becomes: .../api/auth/register

  // If you add a get user route in your auth.routes.ts later:
  static const String users = 'auth/';
  static String userById(String id) => 'auth/$id';

  // ============ Other Endpoints ============
  // These should match whatever prefix you use in app.ts (e.g., app.use('/api/establishments', ...))
  static const String establishments = 'establishments';
  static String establishmentById(String id) => 'establishments/$id';

  static const String categories = 'categories';
  static String categoryById(String id) => 'categories/$id';

  static const String reviews = 'reviews';
  static String reviewsByEstablishment(String estId) =>
      'reviews/establishment/$estId';

  static const String favorites = 'favorites';
  static String userFavorites(String userId) => 'favorites/user/$userId';
}
