import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = true;
  static const String compIpAddress = "192.168.0.104";

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
  static const String searchPicks = 'picks/search';
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
  static const String notificationStream = 'notifications/stream';
  static const String unreadCount = 'notifications/unread-count';
  static const String markRead = 'notifications/read';
  static String deleteNotification(String id) => 'notifications/$id';

  // ============ COMMENTS (Correct path as per backend) ============
  static const String comments = 'social/comment';
  static String editComment(String id) => 'social/comment/$id';
  static String removeComment(String id) => 'social/comment/$id';

  // ============ MAP / GEOSPATIAL ============
  static const String nearbyPicks = 'map/nearby';

  // ============ BLOGS ============
  static const String blogs = 'blogs';

  // ============ PASSWORD RESET ============
  static const String requestPasswordReset = 'auth/request-password-reset';
  static String resetPassword(String token) => 'auth/reset-password/$token';

  // ============ PLACE HUB ============
  static String placeProfile(String linkId) => 'picks/place/$linkId';

  /// Resolve a server-relative path (e.g. /uploads/abc.jpg) to a full URL
  static String resolveServerUrl(String path) {
    if (path.startsWith('http')) return path;
    return '$serverBaseUrl$path';
  }
}
