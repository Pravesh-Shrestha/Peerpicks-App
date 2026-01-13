import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/usecases/app_usecases.dart';
import 'package:peerpicks/features/auth/data/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

// Create Provider
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LogoutUseCase(authRepository: authRepository);
});

class LogoutUseCase implements UsecaseWithoutParms<bool> {
  final IAuthRepository _authRepository;

  LogoutUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call() {
    return _authRepository.logout();
  }
}
