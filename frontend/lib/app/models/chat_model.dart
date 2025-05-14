class ChatModel {
  final String uId; // "user" 또는 "gemini"
  final String content;
  final DateTime timestamp;

  ChatModel({
    required this.uId,
    required this.content,
    required this.timestamp,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      uId: json['u_id'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'u_id': uId,
      'content': content,
      'timestamp': timestamp.toUtc(),
    };
  }
}
