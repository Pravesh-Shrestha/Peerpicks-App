import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/usecases/app_usecases.dart';
import 'package:peerpicks/features/picks/data/repositories/picks_repository.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';
import 'package:peerpicks/features/picks/domain/repositories/picks_repository.dart';

class GetPicksByCategoryParams extends Equatable {
  final String category;
  final int page;

  const GetPicksByCategoryParams({required this.category, this.page = 1});

  @override
  List<Object?> get props => [category, page];
}

final getPicksByCategoryUsecaseProvider = Provider<GetPicksByCategoryUsecase>((
  ref,
) {
  final picksRepository = ref.read(picksRepositoryProvider);
  return GetPicksByCategoryUsecase(picksRepository: picksRepository);
});

class GetPicksByCategoryUsecase
    implements UsecaseWithParms<List<PickEntity>, GetPicksByCategoryParams> {
  final IPicksRepository _picksRepository;

  GetPicksByCategoryUsecase({required IPicksRepository picksRepository})
    : _picksRepository = picksRepository;

  @override
  Future<Either<Failure, List<PickEntity>>> call(
    GetPicksByCategoryParams params,
  ) {
    return _picksRepository.getPicksByCategory(
      params.category,
      page: params.page,
    );
  }
}
