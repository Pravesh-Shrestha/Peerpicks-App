import 'package:peerpicks/features/social/data/models/comment_model.dart';
import 'package:peerpicks/features/picks/data/models/pick_model.dart';

abstract interface class ISocialDataSource {
  Future<Map<String, dynamic>> toggleVote(String pickId);
  Future<Map<String, dynamic>> toggleFollow(String targetUserId);
  Future<Map<String, dynamic>> toggleFavorite(String pickId);
  Future<List<PickModel>> getMyFavorites();
  Future<CommentModel> createComment({
    required String pickId,
    required String content,
  });
  Future<CommentModel> updateComment({
    required String commentId,
    required String content,
  });
  Future<bool> deleteComment(String commentId);
  Future<List<CommentModel>> getPickDiscussion(String pickId);
}
