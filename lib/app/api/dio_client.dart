import 'package:dio/dio.dart';
import 'package:template/app/api/api_error.dart';
import 'package:template/app/api/auth_interceptor.dart';
import 'package:template/app/api/result.dart';
import 'package:template/app/auth/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyDio {
  final Dio dio;
  final _host = dotenv.env["API_ADDRESS"].toString();

  MyDio({required this.dio}) {
    dio.options.baseUrl = _host;
    dio.options.connectTimeout = const Duration(milliseconds: 10000);
    dio.options.receiveTimeout = const Duration(milliseconds: 10000);
    dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  void setAuthService(AuthService service) =>
      dio.interceptors.add(AuthInterceptor(authService: service, dio: dio));

  Future<Result<T>> _request<T>({
    required String path,
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (fromJson != null) {
        return Result.success(fromJson(response.data));
      } else {
        return Result.success(response.data as T);
      }
    } on DioException catch (e) {
      return Result.failure(ApiError.fromDioError(e));
    } catch (e) {
      return Result.failure(ApiError.unknown(e));
    }
  }

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return _request<T>(
      path: path,
      method: 'GET',
      queryParameters: queryParameters,
      fromJson: fromJson,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return _request<T>(
      path: path,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return _request<T>(
      path: path,
      method: 'PUT',
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Result<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _request<T>(
      path: path,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  Future<Result<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return _request<T>(
      path: path,
      method: 'PATCH',
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
