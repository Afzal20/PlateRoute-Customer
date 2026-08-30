import 'package:dio/dio.dart';

class IdempotencyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Only apply idempotency keys to mutating requests
    final method = options.method.toUpperCase();
    if (method == 'POST' || method == 'PUT' || method == 'PATCH') {
      // If caller did not provide custom Idempotency-Key, generate one
      if (!options.headers.containsKey('Idempotency-Key')) {
        final generatedKey = _generateIdempotencyKey(options.path);
        options.headers['Idempotency-Key'] = generatedKey;
      }
    }

    return handler.next(options);
  }

  String _generateIdempotencyKey(String path) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final pathSanitized = path.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return 'req_${pathSanitized}_$timestamp';
  }
}
