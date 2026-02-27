import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = false;
  static const String compIpAddress = "192.168.0.1";

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

  static String get serverBaseUrl {
    if (isPhysicalDevice) return 'http://$compIpAddress:3000';
    if (kIsWeb) return 'http://localhost:3000';
    return Platform.isAndroid
        ? 'http://10.0.2.2:3000'
        : 'http://localhost:3000';
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ AUTH (Verified via Integration Tests) ============
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String whoAmI = 'auth/me';
  static const String updateProfile = 'auth/update-profile';

  // ============ PICKS (The Core Engine) ============
  static const String picks = 'picks';
  static const String discoveryFeed = 'picks/feed';
  static String pickDetail(String id) => 'picks/$id';
  static String pickDiscussion(String id) => 'picks/$id/discussion';
  static String picksByUser(String userId) => 'picks/user/$userId';
  static String picksByCategory(String category) => 'picks/category/$category';

  // Protocol Compliance: [2026-02-01] "delete" instead of "purge"
  static String deletePick(String id) => 'picks/$id';

  // ============ SOCIAL & INTERACTIONS ============
  static String vote(String pickId) => 'social/vote/$pickId';
  static String favorite(String pickId) => 'social/favorite/$pickId';
  static const String myFavorites = 'social/favorites';

  static String follow(String userId) => 'social/follow/$userId';
  static String unfollow(String userId) => 'social/unfollow/$userId';

  // ============ COMMENTS ============
  static const String createComment = 'comments';
  static String updateComment(String commentId) => 'comments/$commentId';
  static String deleteComment(String commentId) => 'comments/$commentId';

  // ============ NOTIFICATIONS ============
  static const String notifications = 'notifications';
  static const String unreadCount = 'notifications/unread-count';
  static const String markRead = 'notifications/read';
  static String deleteNotification(String id) => 'notifications/$id';
}
