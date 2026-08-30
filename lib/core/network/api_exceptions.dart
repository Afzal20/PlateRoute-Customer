sealed class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'No internet connection or network timeout',
    super.statusCode,
    super.data,
  });
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Session expired. Please log in again.',
    super.statusCode = 401,
    super.data,
  });
}

class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
    super.statusCode = 403,
    super.data,
  });
}

class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
    super.data,
  });
}

class ValidationException extends ApiException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException({
    super.message = 'Invalid input provided.',
    super.statusCode = 400,
    super.data,
    this.fieldErrors = const {},
  });

  String? getFirstErrorForField(String field) {
    return fieldErrors[field]?.firstOrNull;
  }
}

class ConflictException extends ApiException {
  const ConflictException({
    super.message = 'Conflict with existing resource.',
    super.statusCode = 409,
    super.data,
  });
}

class RateLimitException extends ApiException {
  final int? retryAfterSeconds;

  const RateLimitException({
    super.message = 'Too many requests. Please slow down.',
    super.statusCode = 429,
    super.data,
    this.retryAfterSeconds,
  });
}

class ServerException extends ApiException {
  const ServerException({
    super.message = 'Server encountered an error. Please try again later.',
    super.statusCode = 500,
    super.data,
  });
}

class MaintenanceException extends ApiException {
  final String? minimumVersion;

  const MaintenanceException({
    super.message = 'Service is temporarily under maintenance or app update required.',
    super.statusCode = 503,
    super.data,
    this.minimumVersion,
  });
}

class UnknownApiException extends ApiException {
  const UnknownApiException({
    super.message = 'An unexpected error occurred. Please try again.',
    super.statusCode,
    super.data,
  });
}
