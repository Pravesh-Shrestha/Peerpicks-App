import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';

abstract class IAuthRepository {
  Future<Either<Failure, bool>> register(AuthEntity user);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity>> getUserByEmail(String email);
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, AuthEntity>> getCurrentUser();
}
