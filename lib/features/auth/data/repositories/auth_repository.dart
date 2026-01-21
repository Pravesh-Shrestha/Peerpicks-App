import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/services/connectivity/network_info.dart';
import 'package:peerpicks/features/auth/data/datasources/auth_datasource.dart';
import 'package:peerpicks/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:peerpicks/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:peerpicks/features/auth/data/models/auth_api_model.dart';
import 'package:peerpicks/features/auth/data/models/auth_hive_model.dart';
import 'package:peerpicks/features/auth/domain/entities/auth_entity.dart';
import 'package:peerpicks/features/auth/domain/repositories/auth_repository.dart';

// Create provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authLocalDataSource = ref.read(authLocalDataSourceProvider);
  final authRemoteDataSource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return AuthRepository(
    authLocalDataSource: authLocalDataSource,
    authRemoteDataSource: authRemoteDataSource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authLocalDataSource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final INetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDataSource authLocalDataSource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required INetworkInfo networkInfo,
  }) : _authLocalDataSource = authLocalDataSource,
       _authRemoteDataSource = authRemoteDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    if (await _networkInfo.isConnected) {
      try {
        // Map domain entity to API model for remote registration
        final apiModel = AuthApiModel.fromEntity(user);
        await _authRemoteDataSource.register(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Registration failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        // Offline registration logic
        final existingUser = await _authLocalDataSource.getUserByEmail(
          user.email,
        );
        if (existingUser != null) {
          return const Left(
            LocalDatabaseFailure(
              message: "This email is already registered with PeerPicks",
            ),
          );
        }

        // Map domain entity to Hive model for local storage
        // Using updated fields: gender, dob, phone, profilePicture
        final authHiveModel = AuthHiveModel(
          authId: user.authId,
          fullName: user.fullName,
          email: user.email,
          password: user.password,
          gender: user.gender,
          dob: user.dob,
          phone: user.phone,
          role: user.role,
          profilePicture: user.profilePicture,
        );

        await _authLocalDataSource.register(authHiveModel);
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.login(email, password);
        if (apiModel != null) {
          // Sync with local database after successful remote login
          final authHiveModel = AuthHiveModel.fromEntity(apiModel.toEntity());
          await _authLocalDataSource.register(authHiveModel);

          return Right(apiModel.toEntity());
        }
        return const Left(ApiFailure(message: "Invalid credentials"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(message: e.response?.data['message'] ?? "Login failed"),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Offline login via Hive
      try {
        final model = await _authLocalDataSource.login(email, password);
        if (model != null) {
          return Right(model.toEntity());
        }
        return const Left(
          LocalDatabaseFailure(
            message: "Offline login failed. Check credentials.",
          ),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final model = await _authLocalDataSource.getCurrentUser();
      if (model != null) {
        return Right(model.toEntity());
      }
      return const Left(LocalDatabaseFailure(message: "Session expired"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authLocalDataSource.logout();
      return Right(result);
    } catch (e) {
      return Left(
        LocalDatabaseFailure(message: "Logout failed: ${e.toString()}"),
      );
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getUserByEmail(String email) async {
    try {
      final model = await _authLocalDataSource.getUserByEmail(email);
      if (model != null) {
        return Right(model.toEntity());
      }
      return const Left(LocalDatabaseFailure(message: "No user found locally"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
