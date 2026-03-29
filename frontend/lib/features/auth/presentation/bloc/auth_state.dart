import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — we haven't checked auth status yet.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Checking credentials / signing in / signing up.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated.
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// User is NOT authenticated.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Something went wrong (bad credentials, network error, etc.).
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
