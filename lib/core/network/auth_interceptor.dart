import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService secureStorage;
  final Dio dio;
  bool _isRefreshing = false;

  AuthInterceptor({
    required this.secureStorage,
    required this.dio,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if endpoint requires auth exemption
    final isAuthExempt = _isAuthExempt(options.path);
    if (!isAuthExempt) {
      final token = await secureStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isAuthExempt(err.requestOptions.path)) {
      if (!_isRefreshing) {
        _isRefreshing = true;
        final refreshed = await _refreshToken();
        _isRefreshing = false;

        if (refreshed) {
          try {
            final token = await secureStorage.getAccessToken();
            final opts = Options(
              method: err.requestOptions.method,
              headers: {
                ...err.requestOptions.headers,
                'Authorization': 'Bearer $token',
              },
            );

            final response = await dio.request(
              err.requestOptions.path,
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
              options: opts,
            );

            return handler.resolve(response);
          } on DioException catch (retryError) {
            return handler.next(retryError);
          }
        } else {
          await secureStorage.clearTokens();
        }
      }
    }

    return handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dio.options.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final response = await refreshDio.post(
        ApiEndpoints.tokenRefresh,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final access = response.data['access'] as String?;
        final refresh = (response.data['refresh'] as String?) ?? refreshToken;

        if (access != null) {
          await secureStorage.saveTokens(access: access, refresh: refresh);
          return true;
        }
      }
    } catch (_) {
      // Refresh failed
    }

    return false;
  }

  bool _isAuthExempt(String path) {
    return path.contains(ApiEndpoints.login) ||
        path.contains(ApiEndpoints.register) ||
        path.contains(ApiEndpoints.passwordResetOtp) ||
        path.contains(ApiEndpoints.passwordResetConfirm) ||
        path.contains(ApiEndpoints.tokenRefresh) ||
        path.contains(ApiEndpoints.health) ||
        path.contains(ApiEndpoints.config);
  }
}
