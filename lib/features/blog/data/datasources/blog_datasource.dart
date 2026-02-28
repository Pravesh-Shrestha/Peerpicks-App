import 'package:peerpicks/features/blog/data/models/blog_model.dart';

abstract class IBlogDataSource {
  Future<List<BlogModel>> getAllBlogs();
  Future<BlogModel> createBlog({
    required String title,
    required String content,
  });
}
