import 'package:peerpicks/features/auth/domain/entities/auth_entity.dart';
import 'package:peerpicks/core/api/api_client.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';
import 'package:peerpicks/features/auth/data/datasources/auth_datasource.dart';
import 'package:peerpicks/features/auth/data/models/auth_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final response = await _apiClient.get('${ApiEndpoints.users}/$authId');

    if (response.statusCode == 200) {
      // Adjusted to handle direct object or 'data' wrapper common in APIs
      final data = response.data.containsKey('data')
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
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

    // Logs show status 200 and a top-level "token" key
    if (response.statusCode == 200 && response.data['token'] != null) {
      // FIX: Pass the WHOLE response.data to fromJson so it can grab the root 'token'
      // and the nested 'user' object simultaneously
      final userModel = AuthApiModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Persist the session locally
      await _userSessionService.saveUserSession(
        userId: userModel.id ?? "",
        email: userModel.email,
        fullName: userModel.fullName,
        token: userModel.token ?? "", // Now this won't be null!
        phone: userModel.phone,
        dob: userModel.dob,
        profilePicture: userModel.profilePicture, // Ensures image persists
      );

      return userModel;
    }
    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: user.toJson(),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = response.data.containsKey('data')
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }

    return user;
  }
}
