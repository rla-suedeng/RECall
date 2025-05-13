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

  // post /register
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

  /// get /user
  Future<Result<UserModel>> getUser() {
    return _dio.get<UserModel>(
      "/user",
      fromJson: (json) => UserModel.fromJson(json),
    );
  }

  /// post /apply
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
      throw Exception('🟥 Apply Fail: ${response.body}');
    }
  }

  /// get /apply/list
  Future<List<ApplyModel>> getAppliedPatients(String idToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/apply/list'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('🟥 Failed to retrieve list of received applications');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => ApplyModel.fromJson(e)).toList();
  }

  // get /accept
  Future<List<ApplyModel>> getReceivedApplications(String idToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/accept'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('🟥 Failed to retrieve list of received applications');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => ApplyModel.fromJson(e)).toList();
  }

  // delete /reject/{u_id}
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
      throw Exception('🟥 Reject Fail: ${response.body}');
    }
  }

  /// post /accept/{uid}/key=birthday
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
      throw Exception('🟥 Accept Fail: ${response.body}');
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
      return null;
    } else {
      throw Exception('Failed to load linked patient: ${response.body}');
    }
  }
}
