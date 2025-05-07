import 'package:template/app/api/dio_client.dart';
import 'package:template/app/models/user_model.dart';
import 'package:template/app/api/result.dart';

class UserApi {
  final MyDio _dio;

  UserApi(this._dio);

  /// POST /register
  Future<Result<UserModel>> register({
    required String uId,
    required String password,
    required String role,
    String? pId,
    required String fName,
    required String lName,
    required String birthday,
    required String email,
  }) {
    return _dio.post<UserModel>(
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
      fromJson: (json) => UserModel.fromJson(json),
    );
  }

  /// u_id로 사용자 조회
  Future<Result<UserModel>> getUser(String uId) {
    return _dio.get<UserModel>(
      "/users/$uId",
      fromJson: (json) => UserModel.fromJson(json),
    );
  }
}
