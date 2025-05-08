import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../storage/local_storage.dart';
import '../utils/logger.dart';
import 'failures.dart';

class ErrorHandler {
  static Failure handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else {
      return UnknownFailure(message: error.toString());
    }
  }

  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure(message: 'Connection timed out');

      case DioExceptionType.badResponse:
        return _handleBadResponseError(error);

      case DioExceptionType.cancel:
        return RequestCancelledFailure();

      case DioExceptionType.connectionError:
        return ConnectionFailure(message: 'No internet connection');

      case DioExceptionType.badCertificate:
        return ServerFailure(message: 'Bad certificate');

      case DioExceptionType.unknown:
        return UnknownFailure(
            message: error.message ?? 'Unknown error occurred');
    }
  }

  static Failure _handleBadResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    String message = 'Server error';

    if (responseData != null && responseData is Map<String, dynamic>) {
      message = responseData['message'] ?? responseData['error'] ?? message;
    }

    switch (statusCode) {
      case 400:
        return BadRequestFailure(message: message);
      case 401:
        _handleUnauthorized();
        return UnauthorizedFailure(message: message);
      case 403:
        return ForbiddenFailure(message: message);
      case 404:
        return NotFoundFailure(message: message);
      case 409:
        return ConflictFailure(message: message);
      case 429:
        return TooManyRequestsFailure(message: message);
      case 500:
      case 501:
      case 502:
      case 503:
        return ServerFailure(message: message);
      default:
        return UnknownFailure(message: message);
    }
  }

  static void _handleUnauthorized() {
    final localStorage = Get.find<LocalStorage>();
    localStorage.setLoggedIn(false);
    localStorage.remove('token');

    if (!Get.currentRoute.contains('/login')) {}
  }

  static void logError(dynamic e) {
    AppLogger.e('Error occurred', error: e);
  }
}
