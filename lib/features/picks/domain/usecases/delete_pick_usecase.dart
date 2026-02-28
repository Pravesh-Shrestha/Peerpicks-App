import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/usecases/app_usecases.dart';
import 'package:peerpicks/features/picks/data/repositories/picks_repository.dart';
import 'package:peerpicks/features/picks/domain/repositories/picks_repository.dart';

class DeletePickParams extends Equatable {
  final String id;

  const DeletePickParams({required this.id});

  @override
  List<Object?> get props => [id];
}

final deletePickUsecaseProvider = Provider<DeletePickUsecase>((ref) {
  final picksRepository = ref.read(picksRepositoryProvider);
  return DeletePickUsecase(picksRepository: picksRepository);
});

class DeletePickUsecase implements UsecaseWithParms<bool, DeletePickParams> {
  final IPicksRepository _picksRepository;

  DeletePickUsecase({required IPicksRepository picksRepository})
    : _picksRepository = picksRepository;

  @override
  Future<Either<Failure, bool>> call(DeletePickParams params) {
    return _picksRepository.deletePick(params.id);
  }
}
