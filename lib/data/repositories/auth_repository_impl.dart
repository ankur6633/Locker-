import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../datasources/remote/auth_remote_data_source.dart';
import '../datasources/local/auth_local_data_source.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<({Failure? failure, User? user, String? token})> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      if (result.exception != null) {
        return (
          failure: _mapExceptionToFailure(result.exception!),
          user: null,
          token: null,
        );
      }

      if (result.user != null && result.token != null) {
        // Save token and user locally
        await _localDataSource.saveToken(result.token!);
        await _localDataSource.saveUser(result.user!);
        await _localDataSource.saveLoginStatus(true);

        return (
          failure: null,
          user: result.user!,
          token: result.token!,
        );
      }

      return (
        failure: const AuthFailure('Login failed'),
        user: null,
        token: null,
      );
    } catch (e) {
      return (
        failure: const NetworkFailure('Network error occurred'),
        user: null,
        token: null,
      );
    }
  }

  @override
  Future<Failure?> logout() async {
    try {
      await _localDataSource.clearToken();
      await _localDataSource.clearUser();
      await _localDataSource.saveLoginStatus(false);
      return null;
    } catch (e) {
      return const CacheFailure('Failed to clear local data');
    }
  }

  @override
  Future<({Failure? failure, User? user})> getCurrentUser() async {
    try {
      final user = await _localDataSource.getUser();
      if (user == null) {
        return (failure: const CacheFailure('No user found'), user: null);
      }
      return (failure: null, user: user);
    } catch (e) {
      return (failure: const CacheFailure('Failed to get user'), user: null);
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _localDataSource.getLoginStatus();
  }

  @override
  Future<String?> getToken() async {
    return await _localDataSource.getToken();
  }

  @override
  Future<void> saveToken(String token) async {
    await _localDataSource.saveToken(token);
  }

  @override
  Future<void> clearToken() async {
    await _localDataSource.clearToken();
  }

  Failure _mapExceptionToFailure(Exception exception) {
    if (exception is AuthException) {
      return AuthFailure(exception.message);
    }
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    }
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    }
    return NetworkFailure('An error occurred');
  }
}
