import 'package:dio/dio.dart';
import 'package:template/app/api/dio_client.dart';
import 'package:template/app/api/result.dart';
import 'package:template/app/auth/auth_service.dart';
import 'package:get_it/get_it.dart';
import 'package:template/app/model/some_model.dart';

class ApiService {
  static ApiService get I => GetIt.I<ApiService>();

  late final MyDio _dio;

  void setAuthService(AuthService authService) =>
      _dio.setAuthService(authService);

  ApiService() {
    _dio = MyDio(dio: Dio());
  }

  Future<Result<SomeModel>> exampleApi(int id) => _dio.get(
        '/example/$id',
        fromJson: SomeModel.fromJson,
      );
}
