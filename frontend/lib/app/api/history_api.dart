import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:template/app/models/history_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HistoryApi {
  final String? _token;
  final baseUrl = dotenv.env['API_ADDRESS'];

  HistoryApi(this._token);

  Future<List<HistoryModel>> getHistory() async {
    final response = await http.get(
      Uri.parse('$baseUrl/history/'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => HistoryModel.fromJson(e)).toList();
    } else {
      print('❌ history fetch Fail: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to fetch history');
    }
  }

  Future<List<HistoryModel>> getHistoryByRecId(int rId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/history/$rId'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => HistoryModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load history for recId: $rId');
    }
  }
}
