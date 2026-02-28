import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/api/api_client.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:peerpicks/features/social/data/datasources/social_datasource.dart';
import 'package:peerpicks/features/social/data/models/comment_model.dart';
import 'package:peerpicks/features/picks/data/models/pick_model.dart';

final socialRemoteDataSourceProvider = Provider<ISocialDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return SocialRemoteDataSource(client: apiClient);
});

class SocialRemoteDataSource implements ISocialDataSource {
  final ApiClient client;

  SocialRemoteDataSource({required this.client});

  @override
  Future<Map<String, dynamic>> toggleVote(String pickId) async {
    final response = await client.post(ApiEndpoints.vote(pickId));
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> toggleFollow(String targetUserId) async {
    final response = await client.post(ApiEndpoints.follow(targetUserId));
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> toggleFavorite(String pickId) async {
    final response = await client.post(ApiEndpoints.favorite(pickId));
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<PickModel>> getMyFavorites() async {
    final response = await client.get(ApiEndpoints.myFavorites);
    if (response.statusCode == 200) {
      final List data = response.data['data'] as List? ?? [];
      return data.map((json) {
        // Favorites API returns the pick object nested or directly
        final pickJson =
            json is Map<String, dynamic> && json.containsKey('pick')
            ? (json['pick'] is Map<String, dynamic> ? json['pick'] : json)
            : json;
        return PickModel.fromJson(pickJson as Map<String, dynamic>);
      }).toList();
    }
    return [];
  }

  @override
  Future<CommentModel> createComment({
    required String pickId,
    required String content,
  }) async {
    final response = await client.post(
      ApiEndpoints.comments,
      data: {'pickId': pickId, 'content': content},
    );
    return CommentModel.fromJson(response.data['data']);
  }

  @override
  Future<CommentModel> updateComment({
    required String commentId,
    required String content,
  }) async {
    final response = await client.patch(
      ApiEndpoints.editComment(commentId),
      data: {'content': content},
    );
    return CommentModel.fromJson(response.data['data']);
  }

  @override
  Future<bool> deleteComment(String commentId) async {
    final response = await client.delete(ApiEndpoints.removeComment(commentId));
    return response.statusCode == 200;
  }

  @override
  Future<List<CommentModel>> getPickDiscussion(String pickId) async {
    final response = await client.get(ApiEndpoints.pickDiscussion(pickId));
    if (response.statusCode == 200) {
      final data = response.data['data'];
      // The backend returns { parent: {...}, signals: [...], commentCount: n }
      final List comments = data is Map<String, dynamic>
          ? (data['signals'] as List? ?? data['comments'] as List? ?? [])
          : (data as List? ?? []);
      return comments
          .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
