import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/api/api_client.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';
import 'package:peerpicks/features/auth/data/datasources/auth_datasource.dart';
import 'package:peerpicks/features/auth/data/models/auth_api_model.dart';

// Create provider
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthRemoteDatasource(
    apiClient: apiClient,
    userSessionService: userSessionService,
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  @override
  Future<AuthApiModel?> getUserById(String authId) async {
    // Uses the /users/:id endpoint defined in PeerPicks
    final response = await _apiClient.get('${ApiEndpoints.users}/$authId');

    if (response.data["success"] == true) {
      final data = response.data["data"] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }
    return null;
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {"email": email, "password": password},
    );

    // 1. Check status code instead of a "success" key your server might not send
    if (response.statusCode == 200 && response.data['user'] != null) {
      // 2. Access the "user" key directly from the response
      final userData = response.data['user'] as Map<String, dynamic>;
      final String token = response.data['token']; // Extract token

      final user = AuthApiModel.fromJson(userData);

      // 3. Pass the token to the session service so it compiles and works
      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        fullName: user.fullName,
        token: token, // Added token
        phone: user.phone,
        dob: user.dob,
      );

      return user;
    }
    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: user.toJson(),
    );

    if (response.data["success"] == true) {
      final data = response.data["data"] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }

    // Fallback to the original model if registration fails
    // (though usually, the Repository handles the error)
    return user;
  }
}
