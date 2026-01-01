import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_entity.dart';

/// Defines the various states of the authentication process
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registered, // Used to trigger navigation after sign-up
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  /// Factory constructor for the starting state of the app
  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.initial,
      user: null,
      errorMessage: null,
    );
  }

  /// Creates a copy of the current state with updated values.
  /// This is essential for Riverpod to detect changes.
  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
