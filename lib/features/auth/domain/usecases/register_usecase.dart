import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/usecases/app_usecases.dart';
import 'package:peerpicks/features/auth/data/repositories/auth_repository.dart';
import 'package:peerpicks/features/auth/domain/repositories/auth_repository.dart';

import '../entities/auth_entity.dart';

class RegisterParams extends Equatable {
  final String fullName;
  final String email;
  final String username;
  final String password;
  final String? phoneNumber;

  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [fullName, email, username, password, phoneNumber];
}

final registerUsecaseProvider = Provider<RegisterUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUseCase(authRepository: authRepository);
});

class RegisterUseCase implements UsecaseWithParms<bool, RegisterParams> {
  final IAuthRepository _authRepository;

  RegisterUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterParams params) {
    final authEntity = AuthEntity(
      fullName: params.fullName,
      email: params.email,
      username: params.username,
      password: params.password,
      phoneNumber: params.phoneNumber,
    );

    return _authRepository.register(authEntity);
  }
}
