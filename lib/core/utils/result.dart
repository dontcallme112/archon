/// Functional result type для безопасной обработки ошибок
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  const Failure(this.message, {this.error});
}

extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success<T> s => s.data,
        Failure<T> _ => null,
      };

  String? get errorMessage => switch (this) {
        Failure<T> f => f.message,
        Success<T> _ => null,
      };

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String message) onFailure,
  }) =>
      switch (this) {
        Success<T> s => onSuccess(s.data),
        Failure<T> f => onFailure(f.message),
      };
}
