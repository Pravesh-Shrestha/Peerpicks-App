import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/services/connectivity/network_info.dart';
import 'package:peerpicks/features/blog/data/datasources/blog_datasource.dart';
import 'package:peerpicks/features/blog/data/datasources/remote/blog_remote_datasource.dart';
import 'package:peerpicks/features/blog/domain/entities/blog_entity.dart';
import 'package:peerpicks/features/blog/domain/repositories/blog_repository.dart';

class BlogRepository implements IBlogRepository {
  final IBlogDataSource _remoteDataSource;
  final INetworkInfo _networkInfo;

  BlogRepository(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, List<BlogEntity>>> getAllBlogs() async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final models = await _remoteDataSource.getAllBlogs();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data?['message']?.toString() ??
              'Failed to fetch blogs',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogEntity>> createBlog({
    required String title,
    required String content,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final model = await _remoteDataSource.createBlog(
        title: title,
        content: content,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data?['message']?.toString() ??
              'Failed to create blog',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}

final blogRepositoryProvider = Provider<IBlogRepository>((ref) {
  return BlogRepository(
    ref.read(blogRemoteDataSourceProvider),
    ref.read(networkInfoProvider),
  );
});
