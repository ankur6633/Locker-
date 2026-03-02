/// Base exception class
class AppException implements Exception {
  const AppException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Server exception
class ServerException extends AppException {
  const ServerException([super.message = 'Server error', super.statusCode]);
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error']);
}

/// Cache exception
class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed', super.statusCode]);
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed']);
}
