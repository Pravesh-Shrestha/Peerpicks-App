import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';
import 'package:peerpicks/features/auth/domain/entities/auth_entity.dart';
import 'package:peerpicks/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:peerpicks/features/auth/domain/usecases/login_usecase.dart';
import 'package:peerpicks/features/auth/domain/usecases/logout_usecase.dart';
import 'package:peerpicks/features/auth/domain/usecases/register_usecase.dart';
import 'package:peerpicks/features/auth/presentation/state/auth_state.dart';
import 'package:peerpicks/features/auth/presentation/view_model/auth_viewmodel.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockUserSessionService extends Mock implements UserSessionService {}

class FakeRegisterParams extends Fake implements RegisterParams {}

class FakeLoginParams extends Fake implements LoginParams {}

void main() {
  late MockRegisterUseCase registerUseCase;
  late MockLoginUseCase loginUseCase;
  late MockGetCurrentUserUseCase getCurrentUserUseCase;
  late MockLogoutUseCase logoutUseCase;
  late MockUserSessionService userSessionService;
  late AuthEntity user;

  setUpAll(() {
    registerFallbackValue(FakeRegisterParams());
    registerFallbackValue(FakeLoginParams());
  });

  setUp(() {
    registerUseCase = MockRegisterUseCase();
    loginUseCase = MockLoginUseCase();
    getCurrentUserUseCase = MockGetCurrentUserUseCase();
    logoutUseCase = MockLogoutUseCase();
    userSessionService = MockUserSessionService();

    user = AuthEntity(
      authId: 'uid-1',
      fullName: 'Test User',
      email: 'test@example.com',
      password: 'password123',
      gender: 'male',
      dob: DateTime(2000, 1, 1),
      phone: '9800000000',
      token: 'jwt-token',
    );

    when(
      () => getCurrentUserUseCase.call(),
    ).thenAnswer((_) async => Right(user));
    when(
      () => userSessionService.saveUserSession(
        userId: any(named: 'userId'),
        email: any(named: 'email'),
        fullName: any(named: 'fullName'),
        token: any(named: 'token'),
        dob: any(named: 'dob'),
        phone: any(named: 'phone'),
        profilePicture: any(named: 'profilePicture'),
      ),
    ).thenAnswer((_) async {});
  });

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(registerUseCase),
        loginUseCaseProvider.overrideWithValue(loginUseCase),
        getCurrentUserUseCaseProvider.overrideWithValue(getCurrentUserUseCase),
        logoutUseCaseProvider.overrideWithValue(logoutUseCase),
        userSessionServiceProvider.overrideWithValue(userSessionService),
      ],
    );
  }

  Future<void> settleInitialBuild(ProviderContainer container) async {
    container.read(authViewModelProvider);
    await Future<void>.delayed(Duration.zero);
  }

  group('AuthViewModel Unit Tests (10)', () {
    test(
      '1) build triggers getCurrentUser and authenticates on success',
      () async {
        final container = buildContainer();
        addTearDown(container.dispose);

        container.read(authViewModelProvider);
        await Future<void>.delayed(Duration.zero);

        expect(
          container.read(authViewModelProvider).status,
          AuthStatus.authenticated,
        );
        verify(
          () => getCurrentUserUseCase.call(),
        ).called(greaterThanOrEqualTo(1));
      },
    );

    test('2) getCurrentUser sets unauthenticated on failure', () async {
      when(() => getCurrentUserUseCase.call()).thenAnswer(
        (_) async =>
            const Left(LocalDatabaseFailure(message: 'Session expired')),
      );
      final container = buildContainer();
      addTearDown(container.dispose);

      final notifier = container.read(authViewModelProvider.notifier);
      await notifier.getCurrentUser();

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.errorMessage, 'Session expired');
    });

    test('3) register sets registered on success', () async {
      when(
        () => registerUseCase.call(any()),
      ).thenAnswer((_) async => const Right(true));
      final container = buildContainer();
      addTearDown(container.dispose);
      await settleInitialBuild(container);

      final notifier = container.read(authViewModelProvider.notifier);
      await notifier.register(user);

      expect(
        container.read(authViewModelProvider).status,
        AuthStatus.registered,
      );
      verify(() => registerUseCase.call(any())).called(1);
    });

    test('4) register sets error on failure', () async {
      when(() => registerUseCase.call(any())).thenAnswer(
        (_) async => const Left(ApiFailure(message: 'Register failed')),
      );
      final container = buildContainer();
      addTearDown(container.dispose);
      await settleInitialBuild(container);

      final notifier = container.read(authViewModelProvider.notifier);
      await notifier.register(user);

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Register failed');
    });

    test(
      '5) login sets authenticated and persists session when token exists',
      () async {
        when(
          () => loginUseCase.call(any()),
        ).thenAnswer((_) async => Right(user));
        final container = buildContainer();
        addTearDown(container.dispose);
        await settleInitialBuild(container);

        final notifier = container.read(authViewModelProvider.notifier);
        await notifier.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(
          container.read(authViewModelProvider).status,
          AuthStatus.authenticated,
        );
        verify(
          () => userSessionService.saveUserSession(
            userId: any(named: 'userId'),
            email: any(named: 'email'),
            fullName: any(named: 'fullName'),
            token: any(named: 'token'),
            dob: any(named: 'dob'),
            phone: any(named: 'phone'),
            profilePicture: any(named: 'profilePicture'),
          ),
        ).called(1);
      },
    );

    test('6) login sets error when token is missing', () async {
      final userWithoutToken = AuthEntity(
        authId: 'uid-2',
        fullName: 'No Token',
        email: 'notoken@example.com',
        password: 'password123',
        gender: 'male',
        dob: DateTime(2000, 1, 1),
        phone: '9800000001',
      );
      when(
        () => loginUseCase.call(any()),
      ).thenAnswer((_) async => Right(userWithoutToken));

      final container = buildContainer();
      addTearDown(container.dispose);
      await settleInitialBuild(container);

      final notifier = container.read(authViewModelProvider.notifier);
      await notifier.login(
        email: 'notoken@example.com',
        password: 'password123',
      );

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, contains('no token'));
    });

    test('7) login sets error on failure', () async {
      when(() => loginUseCase.call(any())).thenAnswer(
        (_) async => const Left(ApiFailure(message: 'Invalid credentials')),
      );

      final container = buildContainer();
      addTearDown(container.dispose);
      await settleInitialBuild(container);

      final notifier = container.read(authViewModelProvider.notifier);
      await notifier.login(email: 'test@example.com', password: 'bad');

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Invalid credentials');
    });

    test('8) logout sets unauthenticated on success', () async {
      when(
        () => logoutUseCase.call(),
      ).thenAnswer((_) async => const Right(true));
      final container = buildContainer();
      addTearDown(container.dispose);
      await settleInitialBuild(container);

      final notifier = container.read(authViewModelProvider.notifier);
      await notifier.logout();

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, isNull);
    });

    test('9) logout sets error on failure', () async {
      when(() => logoutUseCase.call()).thenAnswer(
        (_) async => const Left(LocalDatabaseFailure(message: 'Logout failed')),
      );
      final container = buildContainer();
      addTearDown(container.dispose);
      await settleInitialBuild(container);

      final notifier = container.read(authViewModelProvider.notifier);
      await notifier.logout();

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Logout failed');
    });

    test('10) clearError clears existing error message', () async {
      when(
        () => loginUseCase.call(any()),
      ).thenAnswer((_) async => const Left(ApiFailure(message: 'Bad login')));
      final container = buildContainer();
      addTearDown(container.dispose);
      await settleInitialBuild(container);

      final notifier = container.read(authViewModelProvider.notifier);
      await notifier.login(email: 'a@b.com', password: 'bad');
      expect(container.read(authViewModelProvider).errorMessage, 'Bad login');

      notifier.clearError();
      expect(container.read(authViewModelProvider).errorMessage, isNull);
    });
  });
}
