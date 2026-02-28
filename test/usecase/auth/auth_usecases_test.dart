import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/features/auth/domain/entities/auth_entity.dart';
import 'package:peerpicks/features/auth/domain/repositories/auth_repository.dart';
import 'package:peerpicks/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:peerpicks/features/auth/domain/usecases/getuser_byemail.dart';
import 'package:peerpicks/features/auth/domain/usecases/login_usecase.dart';
import 'package:peerpicks/features/auth/domain/usecases/logout_usecase.dart';
import 'package:peerpicks/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository repository;
  late AuthEntity user;

  setUpAll(() {
    registerFallbackValue(
      AuthEntity(
        fullName: 'Fallback',
        email: 'fallback@example.com',
        password: 'password123',
        gender: 'male',
        dob: DateTime(2000, 1, 1),
        phone: '9800000000',
      ),
    );
  });

  setUp(() {
    repository = MockAuthRepository();
    user = AuthEntity(
      authId: 'u1',
      fullName: 'Test User',
      email: 'test@example.com',
      password: 'password123',
      gender: 'male',
      dob: DateTime(2000, 1, 1),
      phone: '9800000000',
      token: 'token_123',
    );
  });

  group('UseCase Unit Tests (10)', () {
    test('1) LoginUseCase returns user on success', () async {
      when(
        () => repository.login('test@example.com', 'password123'),
      ).thenAnswer((_) async => Right(user));

      final usecase = LoginUseCase(authRepository: repository);
      final result = await usecase(
        const LoginParams(email: 'test@example.com', password: 'password123'),
      );

      expect(result, Right<Failure, AuthEntity>(user));
      verify(
        () => repository.login('test@example.com', 'password123'),
      ).called(1);
    });

    test('2) LoginUseCase returns failure on invalid credentials', () async {
      const failure = ApiFailure(message: 'Invalid credentials');
      when(
        () => repository.login('test@example.com', 'bad'),
      ).thenAnswer((_) async => const Left(failure));

      final usecase = LoginUseCase(authRepository: repository);
      final result = await usecase(
        const LoginParams(email: 'test@example.com', password: 'bad'),
      );

      expect(result, const Left<Failure, AuthEntity>(failure));
      verify(() => repository.login('test@example.com', 'bad')).called(1);
    });

    test('3) RegisterUseCase maps params and calls repository', () async {
      when(
        () => repository.register(any()),
      ).thenAnswer((_) async => const Right(true));

      final usecase = RegisterUseCase(authRepository: repository);
      final params = RegisterParams(
        fullName: 'Reg User',
        email: 'reg@example.com',
        password: '123456',
        gender: 'female',
        dob: DateTime(1998, 5, 20),
        phone: '9811111111',
        profilePicture: null,
      );

      final result = await usecase(params);

      expect(result, const Right<Failure, bool>(true));
      final captured =
          verify(() => repository.register(captureAny())).captured.single
              as AuthEntity;
      expect(captured.fullName, params.fullName);
      expect(captured.email, params.email);
      expect(captured.role, 'user');
    });

    test('4) RegisterUseCase returns failure', () async {
      const failure = LocalDatabaseFailure(message: 'Already exists');
      when(
        () => repository.register(any()),
      ).thenAnswer((_) async => const Left(failure));

      final usecase = RegisterUseCase(authRepository: repository);
      final params = RegisterParams(
        fullName: 'Reg User',
        email: 'reg@example.com',
        password: '123456',
        gender: 'female',
        dob: DateTime(1998, 5, 20),
        phone: '9811111111',
        profilePicture: null,
      );

      final result = await usecase(params);

      expect(result, const Left<Failure, bool>(failure));
      verify(() => repository.register(any())).called(1);
    });

    test('5) GetCurrentUserUseCase returns current user', () async {
      when(
        () => repository.getCurrentUser(),
      ).thenAnswer((_) async => Right(user));

      final usecase = GetCurrentUserUseCase(authRepository: repository);
      final result = await usecase();

      expect(result, Right<Failure, AuthEntity>(user));
      verify(() => repository.getCurrentUser()).called(1);
    });

    test('6) GetCurrentUserUseCase returns failure', () async {
      const failure = LocalDatabaseFailure(message: 'Session expired');
      when(
        () => repository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(failure));

      final usecase = GetCurrentUserUseCase(authRepository: repository);
      final result = await usecase();

      expect(result, const Left<Failure, AuthEntity>(failure));
      verify(() => repository.getCurrentUser()).called(1);
    });

    test('7) LogoutUseCase returns success', () async {
      when(
        () => repository.logout(),
      ).thenAnswer((_) async => const Right(true));

      final usecase = LogoutUseCase(authRepository: repository);
      final result = await usecase();

      expect(result, const Right<Failure, bool>(true));
      verify(() => repository.logout()).called(1);
    });

    test('8) LogoutUseCase returns failure', () async {
      const failure = LocalDatabaseFailure(message: 'Logout failed');
      when(
        () => repository.logout(),
      ).thenAnswer((_) async => const Left(failure));

      final usecase = LogoutUseCase(authRepository: repository);
      final result = await usecase();

      expect(result, const Left<Failure, bool>(failure));
      verify(() => repository.logout()).called(1);
    });

    test('9) GetUserByEmailUsecase returns user by email', () async {
      when(
        () => repository.getUserByEmail('test@example.com'),
      ).thenAnswer((_) async => Right(user));

      final usecase = GetUserByEmailUsecase(repository);
      final result = await usecase('test@example.com');

      expect(result, Right<Failure, AuthEntity>(user));
      verify(() => repository.getUserByEmail('test@example.com')).called(1);
    });

    test('10) GetUserByEmailUsecase returns failure', () async {
      const failure = LocalDatabaseFailure(message: 'No user found');
      when(
        () => repository.getUserByEmail('missing@example.com'),
      ).thenAnswer((_) async => const Left(failure));

      final usecase = GetUserByEmailUsecase(repository);
      final result = await usecase('missing@example.com');

      expect(result, const Left<Failure, AuthEntity>(failure));
      verify(() => repository.getUserByEmail('missing@example.com')).called(1);
    });
  });
}
