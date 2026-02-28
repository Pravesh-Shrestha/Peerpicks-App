import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/services/connectivity/network_info.dart';
import 'package:peerpicks/features/picks/data/datasources/picks_datasource.dart';
import 'package:peerpicks/features/picks/data/datasources/remote/picks_remote_datasource.dart';
import 'package:peerpicks/features/picks/data/models/pick_model.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';
import 'package:peerpicks/features/picks/domain/repositories/picks_repository.dart';

final picksRepositoryProvider = Provider<IPicksRepository>((ref) {
  final picksRemoteDataSource = ref.read(picksRemoteDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return PicksRepository(
    picksDataSource: picksRemoteDataSource,
    networkInfo: networkInfo,
  );
});

class PicksRepository implements IPicksRepository {
  final IPicksDataSource _picksDataSource;
  final INetworkInfo _networkInfo;

  PicksRepository({
    required IPicksDataSource picksDataSource,
    required INetworkInfo networkInfo,
  }) : _picksDataSource = picksDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<PickEntity>>> getDiscoveryFeed({
    required int page,
    required int limit,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final picks = await _picksDataSource.getDiscoveryFeed(
        page: page,
        limit: limit,
      );
      return Right(PickModel.toEntityList(picks));
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to load discovery feed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PickEntity>> createPick({
    required String alias,
    required double lat,
    required double lng,
    required String description,
    required double stars,
    required List<File> mediaFiles,
    String? category,
    String? parentPickId,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final pick = await _picksDataSource.createPick(
        alias: alias,
        lat: lat,
        lng: lng,
        description: description,
        stars: stars,
        mediaFiles: mediaFiles,
        category: category,
        parentPickId: parentPickId,
      );

      return Right(pick.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to create pick',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PickEntity>> getPickById(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final pick = await _picksDataSource.getPickById(id);
      if (pick == null) {
        return const Left(ApiFailure(message: 'Pick not found'));
      }

      return Right(pick.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to fetch pick',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deletePick(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final isDeleted = await _picksDataSource.deletePick(id);
      if (!isDeleted) {
        return const Left(ApiFailure(message: 'Failed to delete pick'));
      }
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to delete pick',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PickEntity>>> getPicksByCategory(
    String category, {
    int page = 1,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final picks = await _picksDataSource.getPicksByCategory(
        category,
        page: page,
      );
      return Right(PickModel.toEntityList(picks));
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to fetch category picks',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PickEntity>>> getUserPicks(String userId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final picks = await _picksDataSource.getUserPicks(userId);
      return Right(PickModel.toEntityList(picks));
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to fetch user picks',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserProfileWithPicks(
      String userId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final result = await _picksDataSource.getUserProfileWithPicks(userId);
      final profile = result['profile'] as Map<String, dynamic>;
      final picks = result['picks'] as List<PickModel>;
      return Right({
        'profile': profile,
        'picks': PickModel.toEntityList(picks),
      });
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to fetch user profile',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PickEntity>>> searchPicks({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final picks = await _picksDataSource.searchPicks(
        query: query,
        page: page,
        limit: limit,
      );
      return Right(PickModel.toEntityList(picks));
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to search picks',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
