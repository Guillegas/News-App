import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/resources/data_state.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../data_sources/firebase_auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  // ── helpers ──────────────────────────────────────────────

  UserEntity _toEntity(User user) => UserEntity(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
      );

  // ── contract ─────────────────────────────────────────────

  @override
  UserEntity? get currentUser {
    final user = _dataSource.currentUser;
    return user == null ? null : _toEntity(user);
  }

  @override
  Stream<UserEntity?> get authStateChanges =>
      _dataSource.authStateChanges.map((u) => u == null ? null : _toEntity(u));

  @override
  Future<DataState<UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _dataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return DataSuccess(_toEntity(credential.user!));
    } on FirebaseAuthException catch (e) {
      return DataFailed(Exception(_friendlyMessage(e.code)));
    } catch (e) {
      return DataFailed(Exception(e.toString()));
    }
  }

  @override
  Future<DataState<UserEntity>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _dataSource.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName != null && displayName.isNotEmpty) {
        await _dataSource.updateDisplayName(displayName);
      }
      return DataSuccess(_toEntity(credential.user!));
    } on FirebaseAuthException catch (e) {
      return DataFailed(Exception(_friendlyMessage(e.code)));
    } catch (e) {
      return DataFailed(Exception(e.toString()));
    }
  }

  @override
  Future<DataState<UserEntity>> signInWithGoogle() async {
    try {
      final credential = await _dataSource.signInWithGoogle();
      return DataSuccess(_toEntity(credential.user!));
    } on FirebaseAuthException catch (e) {
      return DataFailed(Exception(_friendlyMessage(e.code)));
    } catch (e) {
      return DataFailed(Exception(e.toString()));
    }
  }

  @override
  Future<void> signOut() => _dataSource.signOut();

  // ── friendly error messages ──────────────────────────────

  String _friendlyMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication error: $code';
    }
  }
}
