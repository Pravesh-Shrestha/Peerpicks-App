import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/usecases/app_usecases.dart';
import 'package:peerpicks/features/picks/data/repositories/picks_repository.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';
import 'package:peerpicks/features/picks/domain/repositories/picks_repository.dart';

class GetPickByIdParams extends Equatable {
  final String id;

  const GetPickByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}

final getPickByIdUsecaseProvider = Provider<GetPickByIdUsecase>((ref) {
  final picksRepository = ref.read(picksRepositoryProvider);
  return GetPickByIdUsecase(picksRepository: picksRepository);
});

class GetPickByIdUsecase
    implements UsecaseWithParms<PickEntity, GetPickByIdParams> {
  final IPicksRepository _picksRepository;

  GetPickByIdUsecase({required IPicksRepository picksRepository})
    : _picksRepository = picksRepository;

  @override
  Future<Either<Failure, PickEntity>> call(GetPickByIdParams params) {
    return _picksRepository.getPickById(params.id);
  }
}
