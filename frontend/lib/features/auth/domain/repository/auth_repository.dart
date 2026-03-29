import '../../../../core/resources/data_state.dart';
import '../entities/user_entity.dart';

/// Contract that the data layer must fulfil.
abstract class AuthRepository {
  /// Returns the currently signed-in user, or null.
  UserEntity? get currentUser;

  /// Stream that emits whenever the auth state changes.
  Stream<UserEntity?> get authStateChanges;

  /// Sign in with email & password.
  Future<DataState<UserEntity>> signIn({
    required String email,
    required String password,
  });

  /// Register a new account with email & password.
  Future<DataState<UserEntity>> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign in with Google.
  Future<DataState<UserEntity>> signInWithGoogle();

  /// Sign out the current user.
  Future<void> signOut();
}
