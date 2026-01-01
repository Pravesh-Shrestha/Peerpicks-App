import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/features/auth/data/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

final getUserByEmailProvider = Provider(
  (ref) => GetUserByEmailUsecase(ref.read(authRepositoryProvider)),
);

class GetUserByEmailUsecase {
  final IAuthRepository repository;
  GetUserByEmailUsecase(this.repository);
  Future<Either<Failure, AuthEntity>> call(String email) {
    return repository.getUserByEmail(email);
  }
}
