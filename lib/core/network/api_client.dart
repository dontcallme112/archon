import 'package:dio/dio.dart';

class ApiClient {
  static const _baseUrl = 'https://api.projecthub.app/v1'; // замените на ваш URL

  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }
}

// ─── Auth Interceptor ──────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  // Хранение токена — в продакшене использовать FlutterSecureStorage
  static String? _token;

  static void setToken(String token) => _token = token;
  static void clearToken() => _token = null;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_token != null) {
      options.headers['Authorization'] = 'Bearer $_token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      clearToken();
      // TODO: navigate to login
    }
    handler.next(err);
  }
}

// ─── Logging Interceptor ───────────────────────────────────────────────────

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] → ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ← ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ✗ ${err.response?.statusCode} ${err.requestOptions.path}: ${err.message}');
    handler.next(err);
  }
}

// ─── Error Interceptor ─────────────────────────────────────────────────────

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiError = ApiError.fromDioException(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: apiError,
        response: err.response,
        type: err.type,
      ),
    );
  }
}

// ─── Api Error ────────────────────────────────────────────────────────────

class ApiError implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const ApiError({
    required this.message,
    this.statusCode,
    this.code,
  });

  factory ApiError.fromDioException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiError(message: 'Превышено время ожидания. Проверьте соединение.');
      case DioExceptionType.connectionError:
        return const ApiError(message: 'Нет подключения к интернету.');
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;
        final message = data is Map ? data['message'] ?? 'Ошибка сервера' : 'Ошибка сервера';
        return ApiError(message: message.toString(), statusCode: statusCode);
      default:
        return const ApiError(message: 'Что-то пошло не так. Попробуйте снова.');
    }
  }

  @override
  String toString() => 'ApiError($statusCode): $message';
}
