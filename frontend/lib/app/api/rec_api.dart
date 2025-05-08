import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:template/app/models/rec_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecApi {
  final String? _token;

  RecApi(this._token);

  Future<bool> createRec(RecModel rec) async {
    final baseUrl = dotenv.env['API_ADDRESS'];
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
}
