import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/usecases/app_usecases.dart';
import 'package:peerpicks/features/category/data/repositories/category_repository.dart';
import 'package:peerpicks/features/category/domain/repositories/category_repository.dart';

class DeleteCategoryParams extends Equatable {
  final String categoryId;

  const DeleteCategoryParams({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

final deleteCategoryUsecaseProvider = Provider<DeleteCategoryUsecase>((ref) {
  final categoryRepository = ref.read(categoryRepositoryProvider);
  return DeleteCategoryUsecase(categoryRepository: categoryRepository);
});

class DeleteCategoryUsecase
    implements UsecaseWithParms<bool, DeleteCategoryParams> {
  final ICategoryRepository _categoryRepository;

  DeleteCategoryUsecase({required ICategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository;

  @override
  Future<Either<Failure, bool>> call(DeleteCategoryParams params) {
    return _categoryRepository.deleteCategory(params.categoryId);
  }
}
