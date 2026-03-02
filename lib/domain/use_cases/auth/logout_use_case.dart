import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

/// Logout use case
class LogoutUseCase {
  LogoutUseCase(this._repository);

  final AuthRepository _repository;

  /// Execute logout
  Future<Failure?> call() async {
    return await _repository.logout();
  }
}
