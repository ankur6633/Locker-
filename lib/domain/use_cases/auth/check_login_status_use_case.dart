import '../../repositories/auth_repository.dart';

/// Check login status use case
class CheckLoginStatusUseCase {
  CheckLoginStatusUseCase(this._repository);

  final AuthRepository _repository;

  /// Execute check login status
  Future<bool> call() async {
    return await _repository.isLoggedIn();
  }
}
