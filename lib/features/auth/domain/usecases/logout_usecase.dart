import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/features/auth/data/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(repository: ref.read(authRepositoryProvider));
});

class LogoutUseCase {
  final IAuthRepository repository;

  LogoutUseCase({required this.repository});

  Future<Either<Failure, bool>> execute() async {
    return await repository.logout();
  }
}
