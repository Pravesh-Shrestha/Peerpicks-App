import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/usecases/app_usecases.dart';
import 'package:peerpicks/features/picks/data/repositories/picks_repository.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';
import 'package:peerpicks/features/picks/domain/repositories/picks_repository.dart';

class GetDiscoveryFeedParams extends Equatable {
  final int page;
  final int limit;

  const GetDiscoveryFeedParams({required this.page, required this.limit});

  @override
  List<Object?> get props => [page, limit];
}

final getDiscoveryFeedUsecaseProvider = Provider<GetDiscoveryFeedUsecase>((
  ref,
) {
  final picksRepository = ref.read(picksRepositoryProvider);
  return GetDiscoveryFeedUsecase(picksRepository: picksRepository);
});

class GetDiscoveryFeedUsecase
    implements UsecaseWithParms<List<PickEntity>, GetDiscoveryFeedParams> {
  final IPicksRepository _picksRepository;

  GetDiscoveryFeedUsecase({required IPicksRepository picksRepository})
    : _picksRepository = picksRepository;

  @override
  Future<Either<Failure, List<PickEntity>>> call(
    GetDiscoveryFeedParams params,
  ) {
    return _picksRepository.getDiscoveryFeed(
      page: params.page,
      limit: params.limit,
    );
  }
}
