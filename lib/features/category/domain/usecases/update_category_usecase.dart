import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/usecases/app_usecases.dart';
import 'package:peerpicks/features/category/data/repositories/category_repository.dart';
import 'package:peerpicks/features/category/domain/entities/category_entity.dart';
import 'package:peerpicks/features/category/domain/repositories/category_repository.dart';

class UpdateCategoryParams extends Equatable {
  final String categoryId;
  final String name;
  final String? description;
  final String? status;

  const UpdateCategoryParams({
    required this.categoryId,
    required this.name,
    this.description,
    this.status,
  });

  @override
  List<Object?> get props => [categoryId, name, description, status];
}

final updateCategoryUsecaseProvider = Provider<UpdateCategoryUsecase>((ref) {
  final categoryRepository = ref.read(categoryRepositoryProvider);
  return UpdateCategoryUsecase(categoryRepository: categoryRepository);
});

class UpdateCategoryUsecase
    implements UsecaseWithParms<bool, UpdateCategoryParams> {
  final ICategoryRepository _categoryRepository;

  UpdateCategoryUsecase({required ICategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateCategoryParams params) {
    final categoryEntity = CategoryEntity(
      categoryId: params.categoryId,
      name: params.name,
      description: params.description,
    );

    return _categoryRepository.updateCategory(categoryEntity);
  }
}
