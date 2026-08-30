import 'package:dio/dio.dart';
import 'api_exceptions.dart';

class ErrorMapper {
  static ApiException fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Connection failed. Please check your internet connection.',
          data: error.error,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.cancel:
        return const UnknownApiException(
          message: 'Request was cancelled.',
        );

      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'Security certificate verification failed.',
        );

      case DioExceptionType.unknown:
      default:
        return UnknownApiException(
          message: error.message ?? 'An unexpected error occurred.',
          data: error.error,
        );
    }
  }

  static ApiException _handleBadResponse(Response? response) {
    if (response == null) {
      return const ServerException(message: 'Empty response received from server.');
    }

    final statusCode = response.statusCode ?? 500;
    final responseData = response.data;
    String message = 'Something went wrong';

    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('detail') && responseData['detail'] is String) {
        message = responseData['detail'];
      } else if (responseData.containsKey('message') && responseData['message'] is String) {
        message = responseData['message'];
      } else if (responseData.containsKey('error') && responseData['error'] is String) {
        message = responseData['error'];
      }
    }

    switch (statusCode) {
      case 400:
        final fieldErrors = _extractFieldErrors(responseData);
        return ValidationException(
          message: message == 'Something went wrong' ? 'Please check the information provided.' : message,
          statusCode: 400,
          data: responseData,
          fieldErrors: fieldErrors,
        );

      case 401:
        return UnauthorizedException(
          message: message == 'Something went wrong' ? 'Session expired. Please log in again.' : message,
          data: responseData,
        );

      case 403:
        return ForbiddenException(
          message: message == 'Something went wrong' ? 'Access denied.' : message,
          data: responseData,
        );

      case 404:
        return NotFoundException(
          message: message == 'Something went wrong' ? 'Requested resource not found.' : message,
          data: responseData,
        );

      case 409:
        return ConflictException(
          message: message == 'Something went wrong' ? 'Conflict with another resource.' : message,
          data: responseData,
        );

      case 422:
        final fieldErrors = _extractFieldErrors(responseData);
        return ValidationException(
          message: message,
          statusCode: 422,
          data: responseData,
          fieldErrors: fieldErrors,
        );

      case 429:
        int? retryAfter;
        final retryHeader = response.headers.value('retry-after');
        if (retryHeader != null) {
          retryAfter = int.tryParse(retryHeader);
        }
        return RateLimitException(
          message: message == 'Something went wrong' ? 'Too many requests. Please wait a moment.' : message,
          data: responseData,
          retryAfterSeconds: retryAfter,
        );

      case 503:
        return MaintenanceException(
          message: message == 'Something went wrong' ? 'Server is under maintenance.' : message,
          data: responseData,
        );

      case 500:
      case 502:
      case 504:
      default:
        return ServerException(
          message: 'Server error ($statusCode). Please try again shortly.',
          statusCode: statusCode,
          data: responseData,
        );
    }
  }

  static Map<String, List<String>> _extractFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return const {};
    }

    final fieldErrors = <String, List<String>>{};

    data.forEach((key, value) {
      if (key == 'detail' || key == 'message' || key == 'error') return;

      if (value is List) {
        fieldErrors[key] = value.map((e) => e.toString()).toList();
      } else if (value is String) {
        fieldErrors[key] = [value];
      }
    });

    return fieldErrors;
  }
}
