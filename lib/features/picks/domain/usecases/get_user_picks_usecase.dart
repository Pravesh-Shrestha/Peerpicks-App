import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/usecases/app_usecases.dart';
import 'package:peerpicks/features/picks/data/repositories/picks_repository.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';
import 'package:peerpicks/features/picks/domain/repositories/picks_repository.dart';

class GetUserPicksParams extends Equatable {
  final String userId;

  const GetUserPicksParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final getUserPicksUsecaseProvider = Provider<GetUserPicksUsecase>((ref) {
  final picksRepository = ref.read(picksRepositoryProvider);
  return GetUserPicksUsecase(picksRepository: picksRepository);
});

class GetUserPicksUsecase
    implements UsecaseWithParms<List<PickEntity>, GetUserPicksParams> {
  final IPicksRepository _picksRepository;

  GetUserPicksUsecase({required IPicksRepository picksRepository})
    : _picksRepository = picksRepository;

  @override
  Future<Either<Failure, List<PickEntity>>> call(GetUserPicksParams params) {
    return _picksRepository.getUserPicks(params.userId);
  }
}
