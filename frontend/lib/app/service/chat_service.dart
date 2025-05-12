import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:typed_data';

class ChatService {
  WebSocketChannel? _channel;

  void connect(String token) {
    if (_channel != null) return; // 이미 연결되어 있으면 생략
    final uri = Uri.parse(
        'ws://192.168.45.143:8000/chat/voice-chat?token=Bearer $token');
    _channel = WebSocketChannel.connect(uri);
  }

  void sendAudio(Uint8List audioBytes) {
    _channel?.sink.add(audioBytes);
  }

  void listen(void Function(String message) onMessage) {
    _channel?.stream.listen(
      (data) {
        onMessage(data);
      },
      onError: (error) {
        print("❌ WebSocket 오류: $error");
      },
      onDone: () {
        print("🔌 WebSocket 연결 종료됨");
      },
    );
  }

  void close() {
    _channel?.sink.close(status.goingAway);
  }
}
