import 'dart:io';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/services/connectivity/network_info.dart';
import 'package:peerpicks/core/services/storage/storage_service.dart';
import 'package:peerpicks/features/picks/data/datasources/picks_datasource.dart';
import 'package:peerpicks/features/picks/data/datasources/remote/picks_remote_datasource.dart';
import 'package:peerpicks/features/picks/data/models/pick_model.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';
import 'package:peerpicks/features/picks/domain/repositories/picks_repository.dart';

final picksRepositoryProvider = Provider<IPicksRepository>((ref) {
  final picksRemoteDataSource = ref.read(picksRemoteDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final storageService = ref.read(storageServiceProvider);

  return PicksRepository(
    picksDataSource: picksRemoteDataSource,
    networkInfo: networkInfo,
    storageService: storageService,
  );
});

class PicksRepository implements IPicksRepository {
  static const String _discoveryFeedCachePrefix = 'cache.picks.discovery';
  static const String _pickByIdCachePrefix = 'cache.picks.byid';

  final IPicksDataSource _picksDataSource;
  final INetworkInfo _networkInfo;
  final StorageService _storageService;

  PicksRepository({
    required IPicksDataSource picksDataSource,
    required INetworkInfo networkInfo,
    required StorageService storageService,
  }) : _picksDataSource = picksDataSource,
       _networkInfo = networkInfo,
       _storageService = storageService;

  @override
  Future<Either<Failure, List<PickEntity>>> getDiscoveryFeed({
    required int page,
    required int limit,
  }) async {
    final cacheKey = _discoveryFeedCacheKey(page: page, limit: limit);

    if (!await _networkInfo.isConnected) {
      final cached = _getCachedPickList(cacheKey);
      if (cached != null) {
        return Right(cached);
      }
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final picks = await _picksDataSource.getDiscoveryFeed(
        page: page,
        limit: limit,
      );
      final entities = PickModel.toEntityList(picks);
      await _savePickListCache(cacheKey, entities);
      for (final pick in entities) {
        await _savePickByIdCache(pick);
      }
      return Right(entities);
    } on DioException catch (e) {
      final cached = _getCachedPickList(cacheKey);
      if (cached != null) {
        return Right(cached);
      }
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
      final cachedPick = _getCachedPickById(id);
      if (cachedPick != null) {
        return Right(cachedPick);
      }
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final pick = await _picksDataSource.getPickById(id);
      if (pick == null) {
        return const Left(ApiFailure(message: 'Pick not found'));
      }

      final entity = pick.toEntity();
      await _savePickByIdCache(entity);
      return Right(entity);
    } on DioException catch (e) {
      final cachedPick = _getCachedPickById(id);
      if (cachedPick != null) {
        return Right(cachedPick);
      }
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
  Future<Either<Failure, PickEntity>> updatePick({
    required String id,
    required String alias,
    required String description,
    required double stars,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final pick = await _picksDataSource.updatePick(
        id: id,
        alias: alias,
        description: description,
        stars: stars,
      );

      return Right(pick.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to update pick',
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
    String userId,
  ) async {
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
          message:
              e.response?.data['message'] ?? 'Failed to fetch user profile',
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

  String _discoveryFeedCacheKey({required int page, required int limit}) {
    return '$_discoveryFeedCachePrefix.$page.$limit.v1';
  }

  String _pickByIdCacheKey(String id) {
    return '$_pickByIdCachePrefix.$id.v1';
  }

  Future<void> _savePickListCache(String key, List<PickEntity> picks) async {
    final encoded = jsonEncode(picks.map(_pickToMap).toList());
    await _storageService.setData(key, encoded);
  }

  Future<void> _savePickByIdCache(PickEntity pick) async {
    final encoded = jsonEncode(_pickToMap(pick));
    await _storageService.setData(_pickByIdCacheKey(pick.id), encoded);
  }

  List<PickEntity>? _getCachedPickList(String key) {
    final raw = _storageService.getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_pickFromMap)
          .toList();
    } catch (_) {
      return null;
    }
  }

  PickEntity? _getCachedPickById(String id) {
    final raw = _storageService.getString(_pickByIdCacheKey(id));
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return _pickFromMap(decoded);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _pickToMap(PickEntity pick) {
    return {
      'id': pick.id,
      'userId': pick.userId,
      'placeId': pick.placeId,
      'alias': pick.alias,
      'stars': pick.stars,
      'description': pick.description,
      'mediaUrls': pick.mediaUrls,
      'tags': pick.tags,
      'category': pick.category,
      'userName': pick.userName,
      'userProfilePicture': pick.userProfilePicture,
      'locationName': pick.locationName,
      'hasUpvoted': pick.hasUpvoted,
      'upvoteCount': pick.upvoteCount,
      'downvoteCount': pick.downvoteCount,
      'commentCount': pick.commentCount,
      'latitude': pick.latitude,
      'longitude': pick.longitude,
      'createdAt': pick.createdAt.toIso8601String(),
    };
  }

  PickEntity _pickFromMap(Map<String, dynamic> map) {
    return PickEntity(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      placeId: map['placeId']?.toString() ?? '',
      alias: map['alias']?.toString() ?? '',
      stars: (map['stars'] as num?)?.toDouble() ?? 0,
      description: map['description']?.toString() ?? '',
      mediaUrls: (map['mediaUrls'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      tags: (map['tags'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      category: map['category']?.toString(),
      userName: map['userName']?.toString(),
      userProfilePicture: map['userProfilePicture']?.toString(),
      locationName: map['locationName']?.toString(),
      hasUpvoted: map['hasUpvoted'] == true,
      upvoteCount: (map['upvoteCount'] as num?)?.toInt() ?? 0,
      downvoteCount: (map['downvoteCount'] as num?)?.toInt() ?? 0,
      commentCount: (map['commentCount'] as num?)?.toInt() ?? 0,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
