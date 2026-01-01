import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/usecases/app_usecases.dart';
import 'package:peerpicks/features/auth/data/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

// Create Provider
final logoutUseCaseProvider = Provider<LogoutUsCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LogoutUsCase(authRepository: authRepository);
});

class LogoutUsCase implements UsecaseWithoutParms<bool> {
  final IAuthRepository _authRepository;

  LogoutUsCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call() {
    return _authRepository.logout();
  }
}
