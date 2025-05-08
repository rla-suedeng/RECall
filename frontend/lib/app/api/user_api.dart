import 'package:template/app/api/dio_client.dart';
import 'package:template/app/models/user_model.dart';
import 'package:template/app/api/result.dart';

class UserApi {
  final MyDio _dio;

  UserApi(this._dio);

  void setAuthToken(String token) {
    _dio.dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// POST /register
  Future<Result<String>> register({
    required String uId,
    required String password,
    required bool role,
    String? pId,
    required String fName,
    required String lName,
    required String birthday,
    required String email,
  }) {
    return _dio.post<String>(
      "/register",
      data: {
        "u_id": uId,
        "password": password,
        "role": role,
        "p_id": pId,
        "f_name": fName,
        "l_name": lName,
        "birthday": birthday,
        "email": email,
      },
      fromJson: (json) => json['message'] as String,
    );
  }

  /// 사용자 조회
  Future<Result<UserModel>> getUser() {
    return _dio.get<UserModel>(
      "/user",
      fromJson: (json) => UserModel.fromJson(json),
    );
  }
}
