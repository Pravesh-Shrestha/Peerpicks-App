class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  static const String baseUrl = 'http://192.168.1.127:3000/api/v1';
  //static const String baseUrl = 'http://localhost:3000/api/v1';
  // For Android Emulator use: 'http://10.0.2.2:3000/api/v1'
  // For iOS Simulator use: 'http://localhost:5000/api/v1'
  // For Physical Device use your computer's IP: 'http://192.168.x.x:5000/api/v1'

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Auth/User Endpoints ============
  static const String users = '/users';
  static const String login = '/users/login';
  static const String register = '/users/register';
  static String userById(String id) => '/users/$id';

  // ============ Establishment Endpoints ============
  static const String establishments = '/establishments';
  static String establishmentById(String id) => '/establishments/$id';

  // ============ Category Endpoints ============
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // ============ Review Endpoints ============
  static const String reviews = '/reviews';
  static String reviewsByEstablishment(String estId) =>
      '/reviews/establishment/$estId';

  // ============ Favorite Endpoints ============
  static const String favorites = '/favorites';
  static String userFavorites(String userId) => '/favorites/user/$userId';
}
