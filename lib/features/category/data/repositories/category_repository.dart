import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/features/category/data/datasources/category_datasource.dart';
import 'package:peerpicks/features/category/data/datasources/local/category_local_datasource.dart';
import 'package:peerpicks/features/category/data/models/category_hive_model.dart';
import 'package:peerpicks/features/category/domain/entities/category_entity.dart';
import 'package:peerpicks/features/category/domain/repositories/category_repository.dart';


final categoryRepositoryProvider = Provider<ICategoryRepository>((ref) {
  final categoryDatasource = ref.read(categoryLocalDatasourceProvider);
  return CategoryRepository(categoryDatasource: categoryDatasource);
});

class CategoryRepository implements ICategoryRepository {
  final ICategoryDataSource _categoryDataSource;

  CategoryRepository({required ICategoryDataSource categoryDatasource})
    : _categoryDataSource = categoryDatasource;

  @override
  Future<Either<Failure, bool>> createCategory(CategoryEntity category) async {
    try {
      final categoryModel = CategoryHiveModel.fromEntity(category);
      final result = await _categoryDataSource.createCategory(categoryModel);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: "Failed to create category"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCategory(String categoryId) async {
    try {
      final result = await _categoryDataSource.deleteCategory(categoryId);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: "Failed to delete category"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories() async {
    try {
      final models = await _categoryDataSource.getAllCategories();
      final entities = CategoryHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryById(
    String categoryId,
  ) async {
    try {
      final model = await _categoryDataSource.getCategoryById(categoryId);
      if (model != null) {
        final entity = model.toEntity();
        return Right(entity);
      }
      return const Left(LocalDatabaseFailure(message: 'Category not found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateCategory(CategoryEntity category) async {
    try {
      final categoryModel = CategoryHiveModel.fromEntity(category);
      final result = await _categoryDataSource.updateCategory(categoryModel);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: "Failed to update category"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
