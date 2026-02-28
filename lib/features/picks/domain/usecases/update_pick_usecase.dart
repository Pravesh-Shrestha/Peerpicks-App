import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/usecases/app_usecases.dart';
import 'package:peerpicks/features/picks/data/repositories/picks_repository.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';
import 'package:peerpicks/features/picks/domain/repositories/picks_repository.dart';

class UpdatePickParams extends Equatable {
  final String id;
  final String alias;
  final String description;
  final double stars;

  const UpdatePickParams({
    required this.id,
    required this.alias,
    required this.description,
    required this.stars,
  });

  @override
  List<Object?> get props => [id, alias, description, stars];
}

final updatePickUsecaseProvider = Provider<UpdatePickUsecase>((ref) {
  final picksRepository = ref.read(picksRepositoryProvider);
  return UpdatePickUsecase(picksRepository: picksRepository);
});

class UpdatePickUsecase
    implements UsecaseWithParms<PickEntity, UpdatePickParams> {
  final IPicksRepository _picksRepository;

  UpdatePickUsecase({required IPicksRepository picksRepository})
    : _picksRepository = picksRepository;

  @override
  Future<Either<Failure, PickEntity>> call(UpdatePickParams params) {
    return _picksRepository.updatePick(
      id: params.id,
      alias: params.alias,
      description: params.description,
      stars: params.stars,
    );
  }
}
