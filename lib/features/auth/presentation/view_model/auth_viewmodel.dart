import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';
import 'package:peerpicks/features/auth/domain/entities/auth_entity.dart';
import 'package:peerpicks/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:peerpicks/features/auth/domain/usecases/login_usecase.dart';
import 'package:peerpicks/features/auth/domain/usecases/logout_usecase.dart';
import 'package:peerpicks/features/auth/domain/usecases/register_usecase.dart';
import 'package:peerpicks/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUseCase _registerUseCase;
  late final LoginUseCase _loginUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final LogoutUseCase _logoutUseCase;

  @override
  AuthState build() {
    _registerUseCase = ref.read(registerUsecaseProvider);
    _loginUseCase = ref.read(loginUseCaseProvider);
    _getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
    _logoutUseCase = ref.read(logoutUseCaseProvider);

    Future.microtask(() => getCurrentUser());

    return const AuthState();
  }

  /// Handles user registration
  Future<void> register(AuthEntity user) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _registerUseCase(
      RegisterParams(
        fullName: user.fullName,
        email: user.email,
        password: user.password!,
        gender: user.gender,
        dob: user.dob,
        phone: user.phone,
        profilePicture: user.profilePicture,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(status: AuthStatus.registered),
    );
  }

  /// Handles user login
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    // Using await on fold because we are performing async operations inside
    await result.fold(
      (failure) async {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (user) async {
        final session = ref.read(userSessionServiceProvider);

        // SAFE ACCESS: Use null-coalescing instead of !
        final String safeToken = user.token ?? "";

        if (safeToken.isNotEmpty) {
          // Persist the full session including the profile picture
          await session.saveUserSession(
            userId: user.authId ?? "",
            email: user.email,
            fullName: user.fullName,
            dob: user.dob, // Safe fallback for dob
            token: safeToken,
            profilePicture: user.profilePicture,
          );

          // Update state to authenticated to trigger navigation
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
        } else {
          // If token is missing, update state to error to stop the loading spinner
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage:
                "Login successful but no token was provided by the server.",
          );
        }
      },
    );
  }

  /// Checks if a session exists (e.g., on app startup)
  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  /// Handles user logout
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
