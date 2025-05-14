import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:template/app/models/chat_model.dart';
import 'package:http_parser/http_parser.dart';

class ChatApi {
  final String? _token;
  final String baseUrl = dotenv.env['API_ADDRESS']!;
  ChatApi(this._token);

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      };

  /// post /chat/enter
  Future<Map<String, dynamic>> enterChat() async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/enter'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          '❌ enter_chat 실패: ${response.statusCode} - ${response.body}');
    }
  }

  //post /chat
  Future<String> sendAudioForSTT(Uint8List audioBytes) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/chat'));
    request.headers['Authorization'] = 'Bearer $_token';
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      audioBytes,
      filename: 'voice.mp3',
      contentType: MediaType('audio', 'mpeg'),
    ));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['transcript'];
    } else {
      throw Exception('❌ STT 실패: ${response.body}');
    }
  }

//POST /chat/{h_id}/message
  Future<Map<String, dynamic>> sendMessageWithAudio({
    required String token,
    required int hId,
    required Uint8List audioBytes,
  }) async {
    final uri = Uri.parse('$baseUrl/chat/$hId/message');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        audioBytes,
        filename: 'voice.mp3',
        contentType: MediaType('audio', 'mpeg'),
      ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          '❌ Fail to send Message: ${response.statusCode} - ${response.body}');
    }
  }

  Uint8List decodeAudioBase64(String base64String) {
    return base64Decode(base64String);
  }

  // get /chat/{h_id}
  Future<List<ChatModel>> getChatHistory({required int historyId}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/$historyId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => ChatModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load chat list: ${response.body}');
    }
  }
}
