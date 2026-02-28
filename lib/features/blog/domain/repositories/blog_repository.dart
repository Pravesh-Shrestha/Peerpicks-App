import 'package:dartz/dartz.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/features/blog/domain/entities/blog_entity.dart';

abstract class IBlogRepository {
  Future<Either<Failure, List<BlogEntity>>> getAllBlogs();
  Future<Either<Failure, BlogEntity>> createBlog({
    required String title,
    required String content,
  });
}
