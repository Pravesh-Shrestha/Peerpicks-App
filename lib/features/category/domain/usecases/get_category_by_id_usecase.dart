import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/usecases/app_usecases.dart';
import 'package:peerpicks/features/category/data/repositories/category_repository.dart';
import 'package:peerpicks/features/category/domain/entities/category_entity.dart';
import 'package:peerpicks/features/category/domain/repositories/category_repository.dart';

class GetCategoryByIdParams extends Equatable {
  final String categoryId;

  const GetCategoryByIdParams({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

final getCategoryByIdUsecaseProvider = Provider<GetCategoryByIdUsecase>((ref) {
  final categoryRepository = ref.read(categoryRepositoryProvider);
  return GetCategoryByIdUsecase(categoryRepository: categoryRepository);
});

class GetCategoryByIdUsecase
    implements UsecaseWithParms<CategoryEntity, GetCategoryByIdParams> {
  final ICategoryRepository _categoryRepository;

  GetCategoryByIdUsecase({required ICategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository;

  @override
  Future<Either<Failure, CategoryEntity>> call(GetCategoryByIdParams params) {
    return _categoryRepository.getCategoryById(params.categoryId);
  }
}
