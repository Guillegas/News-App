import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class SignOutUseCase implements UseCase<void, void> {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  @override
  Future<void> call({void params}) {
    return _repository.signOut();
  }
}
