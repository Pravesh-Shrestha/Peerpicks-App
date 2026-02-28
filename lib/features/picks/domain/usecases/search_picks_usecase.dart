import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/usecases/app_usecases.dart';
import 'package:peerpicks/features/picks/data/repositories/picks_repository.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';
import 'package:peerpicks/features/picks/domain/repositories/picks_repository.dart';

class SearchPicksParams extends Equatable {
  final String query;
  final int page;
  final int limit;

  const SearchPicksParams({
    required this.query,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, page, limit];
}

final searchPicksUsecaseProvider = Provider<SearchPicksUsecase>((ref) {
  final picksRepository = ref.read(picksRepositoryProvider);
  return SearchPicksUsecase(picksRepository: picksRepository);
});

class SearchPicksUsecase
    implements UsecaseWithParms<List<PickEntity>, SearchPicksParams> {
  final IPicksRepository _picksRepository;

  SearchPicksUsecase({required IPicksRepository picksRepository})
    : _picksRepository = picksRepository;

  @override
  Future<Either<Failure, List<PickEntity>>> call(SearchPicksParams params) {
    return _picksRepository.searchPicks(
      query: params.query,
      page: params.page,
      limit: params.limit,
    );
  }
}
