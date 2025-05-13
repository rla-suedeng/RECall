import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeApi {
  final String? _token;
  final baseUrl = dotenv.env['API_ADDRESS'];

  HomeApi(this._token);

  Future<Map<String, dynamic>> getHomeInfo() async {
    final response = await http.get(
      Uri.parse('$baseUrl/'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(
          '❌ Failed to load home info: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load home info');
    }
  }
}
