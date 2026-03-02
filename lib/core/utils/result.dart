/// Result class for handling success and failure states
sealed class Result<T> {
  const Result();
}

/// Success result
class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

/// Error result
class Error<T> extends Result<T> {
  const Error(this.failure);

  final String failure;
}
