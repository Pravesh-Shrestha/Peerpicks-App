import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/services/connectivity/network_info.dart';
import 'package:peerpicks/features/social/data/datasources/social_datasource.dart';
import 'package:peerpicks/features/social/data/datasources/remote/social_remote_datasource.dart';
import 'package:peerpicks/features/social/data/models/comment_model.dart';
import 'package:peerpicks/features/social/domain/entities/comment_entity.dart';
import 'package:peerpicks/features/social/domain/repositories/social_repository.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';
import 'package:peerpicks/features/picks/data/models/pick_model.dart';

final socialRepositoryProvider = Provider<ISocialRepository>((ref) {
  final dataSource = ref.read(socialRemoteDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return SocialRepository(dataSource: dataSource, networkInfo: networkInfo);
});

class SocialRepository implements ISocialRepository {
  final ISocialDataSource _dataSource;
  final INetworkInfo _networkInfo;

  SocialRepository({
    required ISocialDataSource dataSource,
    required INetworkInfo networkInfo,
  }) : _dataSource = dataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, Map<String, dynamic>>> toggleVote(
    String pickId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final result = await _dataSource.toggleVote(pickId);
      final userStatus =
          result['data']?['userStatus'] ?? result['userStatus'] ?? 'cleared';
      final upvoteCount =
          result['data']?['upvoteCount'] ?? result['upvoteCount'] ?? 0;
      return Right({
        'isUpvoted': userStatus == 'upvoted',
        'upvoteCount': upvoteCount,
      });
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to vote',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> toggleFollow(
    String targetUserId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final result = await _dataSource.toggleFollow(targetUserId);
      final isFollowing =
          result['data']?['isFollowing'] ?? result['isFollowing'] ?? false;
      final followerCount =
          result['data']?['followerCount'] ?? result['followerCount'] ?? 0;
      final followingCount =
          result['data']?['followingCount'] ?? result['followingCount'] ?? 0;
      return Right({
        'isFollowing': isFollowing as bool,
        'followerCount': followerCount,
        'followingCount': followingCount,
      });
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to follow',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(String pickId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final result = await _dataSource.toggleFavorite(pickId);
      final isSaved = result['data']?['isSaved'] ?? result['isSaved'] ?? false;
      return Right(isSaved as bool);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to save',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PickEntity>>> getMyFavorites() async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final picks = await _dataSource.getMyFavorites();
      return Right(PickModel.toEntityList(picks));
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to load favorites',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> createComment({
    required String pickId,
    required String content,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final comment = await _dataSource.createComment(
        pickId: pickId,
        content: content,
      );
      return Right(comment.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to add comment',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> updateComment({
    required String commentId,
    required String content,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final comment = await _dataSource.updateComment(
        commentId: commentId,
        content: content,
      );
      return Right(comment.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to update comment',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteComment(String commentId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final deleted = await _dataSource.deleteComment(commentId);
      return Right(deleted);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to delete comment',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getPickDiscussion(
    String pickId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final comments = await _dataSource.getPickDiscussion(pickId);
      return Right(CommentModel.toEntityList(comments));
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to load discussion',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
