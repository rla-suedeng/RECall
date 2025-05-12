import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:template/app/models/chat_model.dart'; // ChatModel 정의한 곳
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatApi {
  final String? _token;
  final baseUrl = dotenv.env['API_ADDRESS'];
  ChatApi(
    this._token,
  );

  Future<List<ChatModel>> getChatHistory({required int historyId}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/$historyId'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => ChatModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load chat list: ${response.body}');
    }
  }

  Future<int> createNewHistory() async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );

    print("📡 Response status: ${response.statusCode}");
    print("📡 Response body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final hId = json['h_id'];
      if (hId is int) {
        return hId;
      } else {
        throw Exception('⚠️ h_id가 응답에 없음: ${response.body}');
      }
    } else {
      throw Exception(
          '❌ 히스토리 생성 실패: ${response.statusCode} - ${response.body}');
    }
  }

  // Future<ChatModel> sendUserMessage(String message) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/chat/'), // 실제 주소로 변경
  //     headers: {
  //       'Authorization': 'Bearer $_token',
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(message),
  //   );

  //   if (response.statusCode == 200) {
  //     final json = jsonDecode(response.body);
  //     return ChatModel.fromJson(json);
  //   } else {
  //     throw Exception('Failed to send message: ${response.body}');
  //   }
  // }

  Future<List<int>> sendTTSRequest(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tts'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: text,
    );

    if (response.statusCode == 200) {
      return response.bodyBytes; // 오디오 데이터 반환
    } else {
      throw Exception('TTS 실패: ${response.body}');
    }
  }
}
