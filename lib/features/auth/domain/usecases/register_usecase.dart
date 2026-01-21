import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/usecases/app_usecases.dart';
import 'package:peerpicks/features/auth/data/repositories/auth_repository.dart';
import 'package:peerpicks/features/auth/domain/entities/auth_entity.dart';
import 'package:peerpicks/features/auth/domain/repositories/auth_repository.dart';

// Provider for RegisterUseCase
final registerUsecaseProvider = Provider<RegisterUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUseCase(authRepository: authRepository);
});

// Updated Parameters to match Mongoose Schema
class RegisterParams extends Equatable {
  final String fullName;
  final String email;
  final String password;
  final String gender;
  final DateTime dob;
  final String phone;
  final String? profilePicture;

  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.password,
    required this.gender,
    required this.dob,
    required this.phone,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
    fullName,
    email,
    password,
    gender,
    dob,
    phone,
    profilePicture,
  ];
}

class RegisterUseCase implements UsecaseWithParms<bool, RegisterParams> {
  final IAuthRepository _authRepository;

  RegisterUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterParams params) {
    // Map params to the updated AuthEntity
    final authEntity = AuthEntity(
      fullName: params.fullName,
      email: params.email,
      password: params.password,
      gender: params.gender,
      dob: params.dob,
      phone: params.phone,
      profilePicture: params.profilePicture,
      role: 'user', // Default role for new registrations
    );

    return _authRepository.register(authEntity);
  }
}
