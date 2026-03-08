import 'package:dartz/dartz.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/features/social/domain/entities/comment_entity.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';

abstract interface class ISocialRepository {
  /// Toggle upvote on a pick — returns {isUpvoted, upvoteCount}
  Future<Either<Failure, Map<String, dynamic>>> toggleVote(String pickId);

  /// Toggle follow/unfollow — returns {isFollowing, followerCount, followingCount}
  Future<Either<Failure, Map<String, dynamic>>> toggleFollow(
    String targetUserId,
  );

  /// Toggle favorite/bookmark — returns true if now favorited
  Future<Either<Failure, bool>> toggleFavorite(String pickId);

  /// Get current user's favorited picks
  Future<Either<Failure, List<PickEntity>>> getMyFavorites();

  /// Create a comment on a pick
  Future<Either<Failure, CommentEntity>> createComment({
    required String pickId,
    required String content,
  });

  /// Update a comment
  Future<Either<Failure, CommentEntity>> updateComment({
    required String commentId,
    required String content,
  });

  /// Delete a comment
  Future<Either<Failure, bool>> deleteComment(String commentId);

  /// Get comments/discussion for a pick
  Future<Either<Failure, List<CommentEntity>>> getPickDiscussion(String pickId);
}
