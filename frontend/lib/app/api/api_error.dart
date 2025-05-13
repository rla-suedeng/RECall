// api_error.dart
import 'package:dio/dio.dart';

enum ErrorType {
  network,
  badRequest,
  unauthorized,
  notFound,
  serverError,
  unknown,
}

class ApiError {
  final ErrorType type;
  final String message;
  final int? statusCode;
  final dynamic rawError;

  ApiError({
    required this.type,
    required this.message,
    this.statusCode,
    this.rawError,
  });

  factory ApiError.unknown(dynamic e) {
    return ApiError(
      type: ErrorType.unknown,
      message: "Unknown Error Occured",
      rawError: e,
    );
  }

  factory ApiError.fromDioError(DioException error) {
    final statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return ApiError(
          type: ErrorType.network,
          message: "Network Connection Error.",
          statusCode: statusCode,
          rawError: error,
        );

      case DioExceptionType.badResponse:
        if (statusCode == null) {
          return ApiError(
            type: ErrorType.unknown,
            message: "Unknown Error Occured.",
            rawError: error,
          );
        }

        if (statusCode == 400) {
          return ApiError(
            type: ErrorType.badRequest,
            message: "Unvalid Request",
            statusCode: statusCode,
            rawError: error,
          );
        } else if (statusCode == 401 || statusCode == 403) {
          return ApiError(
            type: ErrorType.unauthorized,
            message: "Fail authentication",
            statusCode: statusCode,
            rawError: error,
          );
        } else if (statusCode == 404) {
          return ApiError(
            type: ErrorType.notFound,
            message: "Cannot find the resource",
            statusCode: statusCode,
            rawError: error,
          );
        } else if (statusCode >= 500) {
          return ApiError(
            type: ErrorType.serverError,
            message: "Server Error Occur",
            statusCode: statusCode,
            rawError: error,
          );
        } else {
          return ApiError(
            type: ErrorType.unknown,
            message: "Unknown Error Occur",
            statusCode: statusCode,
            rawError: error,
          );
        }

      default:
        return ApiError(
          type: ErrorType.unknown,
          message: "Unknown Error Occur",
          rawError: error,
        );
    }
  }
}
