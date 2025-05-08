import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:template/app/models/rec_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecApi {
  final String? _token;
  final baseUrl = dotenv.env['API_ADDRESS'];

  RecApi(this._token);

  Future<bool> createRec(RecModel rec) async {
    final url = Uri.parse('$baseUrl/rec/');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(rec.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Rec 저장 성공: ${response.body}");
      return true;
    } else {
      print("❌ Rec 저장 실패: ${response.statusCode} - ${response.body}");
      return false;
    }
  }

  Future<List<RecModel>> getRecs({
    String? category,
    String? keyword,
    String order = 'desc',
  }) async {
    final uri = Uri.parse('$baseUrl/rec').replace(queryParameters: {
      if (category != null) 'category': category.toLowerCase(),
      if (keyword != null) 'keyword': keyword,
      'order': order,
    });

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => RecModel.fromJson(json)).toList();
    } else {
      print('❌ 목록 불러오기 실패: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to fetch recs');
    }
  }

  Future<RecModel> getRec(int recId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rec/$recId'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return RecModel.fromJson(json);
    } else {
      throw Exception('Failed to load rec: ${response.statusCode}');
    }
  }
}
