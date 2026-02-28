import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/usecases/app_usecases.dart';
import 'package:peerpicks/features/picks/data/repositories/picks_repository.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';
import 'package:peerpicks/features/picks/domain/repositories/picks_repository.dart';

class CreatePickParams extends Equatable {
  final String alias;
  final double lat;
  final double lng;
  final String description;
  final double stars;
  final List<File> mediaFiles;
  final String? category;
  final String? parentPickId;

  const CreatePickParams({
    required this.alias,
    required this.lat,
    required this.lng,
    required this.description,
    required this.stars,
    required this.mediaFiles,
    this.category,
    this.parentPickId,
  });

  @override
  List<Object?> get props => [
    alias,
    lat,
    lng,
    description,
    stars,
    mediaFiles,
    category,
    parentPickId,
  ];
}

final createPickUsecaseProvider = Provider<CreatePickUsecase>((ref) {
  final picksRepository = ref.read(picksRepositoryProvider);
  return CreatePickUsecase(picksRepository: picksRepository);
});

class CreatePickUsecase
    implements UsecaseWithParms<PickEntity, CreatePickParams> {
  final IPicksRepository _picksRepository;

  CreatePickUsecase({required IPicksRepository picksRepository})
    : _picksRepository = picksRepository;

  @override
  Future<Either<Failure, PickEntity>> call(CreatePickParams params) {
    return _picksRepository.createPick(
      alias: params.alias,
      lat: params.lat,
      lng: params.lng,
      description: params.description,
      stars: params.stars,
      mediaFiles: params.mediaFiles,
      category: params.category,
      parentPickId: params.parentPickId,
    );
  }
}
