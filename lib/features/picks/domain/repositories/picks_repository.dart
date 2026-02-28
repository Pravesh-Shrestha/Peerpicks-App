import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';

abstract interface class IPicksRepository {
  Future<Either<Failure, List<PickEntity>>> getDiscoveryFeed({
    required int page,
    required int limit,
  });

  Future<Either<Failure, PickEntity>> createPick({
    required String alias,
    required double lat,
    required double lng,
    required String description,
    required double stars,
    required List<File> mediaFiles,
    String? category,
    String? parentPickId,
  });

  Future<Either<Failure, PickEntity>> getPickById(String id);
  Future<Either<Failure, bool>> deletePick(String id);
  Future<Either<Failure, List<PickEntity>>> getPicksByCategory(
    String category, {
    int page = 1,
  });
  Future<Either<Failure, List<PickEntity>>> getUserPicks(String userId);
  Future<Either<Failure, Map<String, dynamic>>> getUserProfileWithPicks(
      String userId);
  Future<Either<Failure, List<PickEntity>>> searchPicks({
    required String query,
    int page = 1,
    int limit = 20,
  });
}
