import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:template/app/api/dio_client.dart';
import 'package:template/app/api/result.dart';
import 'package:template/app/models/user_model.dart';
import 'package:template/app/models/apply_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserApi {
  final MyDio _dio;

  UserApi(this._dio);

  final String? baseUrl = dotenv.env['API_ADDRESS'];

  void setAuthToken(String token) {
    _dio.dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// 회원가입
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

  /// 사용자 정보 조회
  Future<Result<UserModel>> getUser() {
    return _dio.get<UserModel>(
      "/user",
      fromJson: (json) => UserModel.fromJson(json),
    );
  }

  /// 보호자가 환자에게 신청
  Future<void> applyPatient({
    required String email,
    required String idToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/apply'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('🟥 신청 실패: ${response.body}');
    }
  }

  /// 보호자가 신청한 환자 목록 조회
  Future<List<ApplyModel>> getAppliedPatients(String idToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/apply/list'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('🟥 신청 목록 조회 실패');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => ApplyModel.fromJson(e)).toList();
  }

  /// 환자가 받은 보호자 신청 목록 조회
  Future<List<ApplyModel>> getReceivedApplications(String idToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/accept'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('🟥 받은 신청 목록 조회 실패');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => ApplyModel.fromJson(e)).toList();
  }

  /// 신청 거절 (보호자 or 환자)
  Future<void> rejectApplication({
    required String userId,
    required String idToken,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/reject/$userId'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('🟥 신청 거절 실패: ${response.body}');
    }
  }

  /// 신청 수락 (환자 전용)
  Future<void> acceptApplication({
    required String userId,
    required String birthday,
    required String idToken,
  }) async {
    final uri = Uri.parse('${dotenv.env['API_ADDRESS']}/accept/$userId')
        .replace(queryParameters: {'req': birthday});

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('🟥 신청 수락 실패: ${response.body}');
    }
  }

  Future<ApplyModel?> getLinkedPatient(String idToken) async {
    final uri = Uri.parse('${dotenv.env['API_ADDRESS']}/apply/patient');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ApplyModel.fromJson(data);
    } else if (response.statusCode == 404) {
      return null; // 연결된 환자 없음
    } else {
      throw Exception('Failed to load linked patient: ${response.body}');
    }
  }
}
