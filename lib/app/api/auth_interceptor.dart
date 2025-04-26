import 'package:dio/dio.dart';
import 'package:template/app/auth/auth_service.dart';

class AuthInterceptor extends InterceptorsWrapper {
  final AuthService authService;
  final Dio dio;

  AuthInterceptor({required this.authService, required this.dio});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (authService.state.isLoggedIn) {
      options.headers["Authorization"] =
          "Bearer ${authService.state.accessToken}";
      return super.onRequest(options, handler);
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return super.onError(err, handler);
    }

    try {
      await authService.refreshAccessToken();

      err.requestOptions.headers["Authorization"] =
          "Bearer ${authService.state.accessToken}";

      final res = await dio.fetch(err.requestOptions);

      return handler.resolve(res);
    } catch (error) {
      if (_isTokenError(error)) {
        await authService.handleTokenExpiration();
      }
      if (error is DioException) {
        handler.reject(error);
      }
    }
  }

  bool _isTokenError(Object error) {
    if (error is DioException) {
      return error.response?.statusCode == 401;
    }

    return false;
  }
}
