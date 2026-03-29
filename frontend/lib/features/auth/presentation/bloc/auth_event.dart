import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Internal event fired by the Firebase authStateChanges stream.
class AuthStreamStateChanged extends AuthEvent {
  final bool isAuthenticated;
  final String? uid;
  final String? email;
  final String? displayName;

  const AuthStreamStateChanged({
    required this.isAuthenticated,
    this.uid,
    this.email,
    this.displayName,
  });

  @override
  List<Object?> get props => [isAuthenticated, uid, email, displayName];
}
