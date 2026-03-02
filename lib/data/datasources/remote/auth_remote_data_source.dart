import '../../models/user_model.dart';
import '../../../core/errors/exceptions.dart';
import 'api_client.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
  Future<({Exception? exception, UserModel? user, String? token})> login({
    required String email,
    required String password,
  });
}

/// Implementation of AuthRemoteDataSource
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<({Exception? exception, UserModel? user, String? token})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final user = UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
      final token = response.data['token'] as String;

      return (exception: null, user: user, token: token);
    } on Exception catch (e) {
      return (exception: e, user: null, token: null);
    }
  }
}

/// Mock implementation for development/testing
class AuthRemoteDataSourceMock implements AuthRemoteDataSource {
  @override
  Future<({Exception? exception, UserModel? user, String? token})> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock validation
    if (email == 'test@example.com' && password == 'password123') {
      final user = UserModel(
        id: '1',
        email: email,
        name: 'Test User',
        phoneNumber: '+1234567890',
      );
      const token = 'mock_jwt_token_12345';

      return (exception: null, user: user, token: token);
    }

    return (
      exception: AuthException('Invalid credentials'),
      user: null,
      token: null,
    );
  }
}
