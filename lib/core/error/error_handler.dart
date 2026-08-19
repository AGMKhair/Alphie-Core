import 'package:dio/dio.dart';
import 'failure.dart';

class ErrorHandler {
  static Failure handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkFailure('Connection timed out. Please try again.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          String message = 'Server error occurred.';
          if (data is Map<String, dynamic>) {
            message = data['message'] ?? message;
            if (statusCode == 422) {
              return ValidationFailure(message, data['errors']);
            }
          }
          if (statusCode == 401 || statusCode == 403) {
            return AuthFailure(message, statusCode);
          }
          return ServerFailure(message, statusCode);
        case DioExceptionType.connectionError:
          return const NetworkFailure('No Internet Connection.');
        default:
          return ServerFailure(error.message ?? 'Unexpected error occurred.');
      }
    } else if (error is Failure) {
      return error;
    } else {
      return ServerFailure(error.toString());
    }
  }
}
