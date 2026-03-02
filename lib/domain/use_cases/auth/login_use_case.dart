import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

/// Login use case
class LoginUseCase {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  /// Execute login
  Future<({Failure? failure, User? user, String? token})> call({
    required String email,
    required String password,
  }) async {
    return await _repository.login(email: email, password: password);
  }
}
