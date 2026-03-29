import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/resources/data_state.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/use_cases/sign_in_usecase.dart';
import '../../domain/use_cases/sign_out_usecase.dart';
import '../../domain/use_cases/sign_up_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final AuthRepository _repository;

  late final StreamSubscription _authSub;

  AuthBloc(
    this._signInUseCase,
    this._signUpUseCase,
    this._signOutUseCase,
    this._repository,
  ) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthStreamStateChanged>(_onAuthStateChanged);

    // Listen to Firebase auth state changes and dispatch as events
    // (never emit directly from a stream — use add() instead).
    _authSub = _repository.authStateChanges.listen((user) {
      add(AuthStreamStateChanged(
        isAuthenticated: user != null,
        uid: user?.uid,
        email: user?.email,
        displayName: user?.displayName,
      ));
    });
  }

  Future<void> _onAuthStateChanged(
      AuthStreamStateChanged event, Emitter<AuthState> emit) async {
    // Don't override loading or error states — let the action handler finish.
    if (state is AuthLoading || state is AuthError) return;

    if (event.isAuthenticated) {
      emit(AuthAuthenticated(UserEntity(
        uid: event.uid!,
        email: event.email ?? '',
        displayName: event.displayName,
      )));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    final user = _repository.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignIn(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _signInUseCase.call(
      params: SignInParams(email: event.email, password: event.password),
    );
    if (result is DataSuccess) {
      emit(AuthAuthenticated(result.data!));
    } else {
      emit(AuthError(result.error?.toString() ?? 'Sign in failed'));
      // After showing the error, go back to unauthenticated so the user
      // can try again (the stream listener won't override AuthError).
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignUp(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _signUpUseCase.call(
      params: SignUpParams(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      ),
    );
    if (result is DataSuccess) {
      emit(AuthAuthenticated(result.data!));
    } else {
      emit(AuthError(result.error?.toString() ?? 'Sign up failed'));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onGoogleSignIn(
      AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _repository.signInWithGoogle();
    if (result is DataSuccess) {
      emit(AuthAuthenticated(result.data!));
    } else {
      emit(AuthError(result.error?.toString() ?? 'Google sign in failed'));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await _signOutUseCase.call();
    emit(const AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }
}
