import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/api/api_client.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:peerpicks/features/blog/data/datasources/blog_datasource.dart';
import 'package:peerpicks/features/blog/data/models/blog_model.dart';

class BlogRemoteDataSource implements IBlogDataSource {
  final ApiClient _apiClient;

  BlogRemoteDataSource(this._apiClient);

  @override
  Future<List<BlogModel>> getAllBlogs() async {
    final response = await _apiClient.get(ApiEndpoints.blogs);
    final data = response.data;
    final List list = data is List ? data : (data['blogs'] ?? []);
    return list.map((e) => BlogModel.fromJson(e)).toList();
  }

  @override
  Future<BlogModel> createBlog({
    required String title,
    required String content,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.blogs,
      data: {'title': title, 'content': content},
    );
    return BlogModel.fromJson(response.data);
  }
}

final blogRemoteDataSourceProvider = Provider<IBlogDataSource>((ref) {
  return BlogRemoteDataSource(ref.read(apiClientProvider));
});
