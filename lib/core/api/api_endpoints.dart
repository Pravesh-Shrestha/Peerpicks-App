import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = false;
  static const String compIpAddress = "192.168.0.1";

  // This returns the API base URL
  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:3000/api/';
    }
    if (kIsWeb) {
      return 'http://localhost:3000/api/';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/';
    } else {
      return 'http://localhost:3000/api/';
    }
  }

  // Used for displaying images from the server's static folder
  static String get serverBaseUrl {
    if (isPhysicalDevice) return 'http://$compIpAddress:3000';
    return 'http://10.0.2.2:3000';
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth Routes
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  // Matches router.put("/update-profile", ...) in auth.routes.ts
  static const String updateProfile = 'auth/update-profile';

  static const String users = 'auth/';
  static String userById(String id) => 'auth/$id';

  // ============ Other Endpoints ============
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
