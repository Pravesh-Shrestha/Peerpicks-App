class ApiEndpoints {
  ApiEndpoints._();

  // Updated to Port 5000 to match: const PORT = process.env.PORT || 5000;
  // Use 10.0.2.2 for Android Emulator, or your IP for Physical Devices
  // static const String baseUrl = 'http://192.168.137.1:3000/api/';
  // static const String baseUrl = 'http://localhost:3000/api/';
  static const String baseUrl = 'http://10.0.2.2:3000/api/';

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
