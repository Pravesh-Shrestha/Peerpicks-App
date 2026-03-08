import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// Use a provider for SecureStorage to keep it a singleton
final storageProvider = Provider((ref) => const FlutterSecureStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(storageProvider);
  return ApiClient(storage);
});

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add Security Interceptor (Passing storage instance)
    _dio.interceptors.add(_AuthInterceptor(_storage));

    // Auto retry on network failures
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        // Updated evaluator to handle newer DioException logic
        retryEvaluator: (error, attempt) {
          if (error.type == DioExceptionType.badResponse) {
            final statusCode = error.response?.statusCode;
            // Don't retry if the server explicitly rejected the request
            if (statusCode != null && statusCode >= 400 && statusCode < 500) {
              return false;
            }
          }
          return error.type != DioExceptionType.cancel;
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  // Reusable method for all requests to handle common logic/errors
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> patch(String path, {dynamic data, Options? options}) async {
    return _dio.patch(path, data: data, options: options);
  }

  Future<Response> put(String path, {dynamic data, Options? options}) async {
    return _dio.put(path, data: data, options: options);
  }

  // Protocol Compliance: Replaced all "purge" logic with "delete" [2026-02-01]
  Future<Response> delete(String path, {dynamic data, Options? options}) async {
    return _dio.delete(path, data: data, options: options);
  }

  Future<Response> uploadFile(
    String path, {
    required FormData formData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    return _dio.post(
      path,
      data: formData,
      options: options?.copyWith(contentType: 'multipart/form-data'),
      onSendProgress: onSendProgress,
    );
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'auth_token';

  _AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Check if it's a public endpoint
    final publicPaths = [ApiEndpoints.login, ApiEndpoints.register];
    final isPublic = publicPaths.any((path) => options.path.contains(path));

    if (!isPublic) {
      final token = await _storage.read(key: _tokenKey);

      // Match axios.ts logic: Only attach if token is valid
      if (token != null && token != "null" && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If we get a 401, the session is expired
    if (err.response?.statusCode == 401) {
      debugPrint('Session expired. Clearing token...');
      await _storage.delete(key: _tokenKey);
      // Optional: Add logic here to trigger a logout in your StateNotifier
    }
    handler.next(err);
  }
}
