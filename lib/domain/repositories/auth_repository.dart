import '../entities/user.dart';
import '../../core/errors/failures.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Login with email and password
  Future<({Failure? failure, User? user, String? token})> login({
    required String email,
    required String password,
  });

  /// Logout user
  Future<Failure?> logout();

  /// Get current user
  Future<({Failure? failure, User? user})> getCurrentUser();

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Get stored auth token
  Future<String?> getToken();

  /// Save auth token
  Future<void> saveToken(String token);

  /// Clear auth token
  Future<void> clearToken();
}
