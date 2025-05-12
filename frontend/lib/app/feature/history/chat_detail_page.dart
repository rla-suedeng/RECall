// ✅ ChatHistoryPage에서 특정 history를 눌렀을 때 채팅 내용을 보여주는 ChatDetailPage로 이동
// ✅ ChatApi의 getChatHistory를 사용해 히스토리 ID에 해당하는 채팅을 불러오도록 구성

// 먼저, ChatDetailPage를 생성해야 함:

import 'package:flutter/material.dart';
import 'package:template/app/models/chat_model.dart';
import 'package:template/app/api/chat_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatDetailPage extends StatefulWidget {
  final int historyId;
  const ChatDetailPage({super.key, required this.historyId});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  List<ChatModel> chatList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChatHistory();
  }

  Future<void> fetchChatHistory() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    final chatApi = ChatApi(token);
    try {
      final result = await chatApi.getChatHistory(historyId: widget.historyId);
      setState(() {
        chatList = result;
        isLoading = false;
      });
    } catch (e) {
      print('❌ 채팅 로딩 실패: $e');
      setState(() => isLoading = false);
    }
  }

  String formatTimestamp(DateTime dt) {
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Detail')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatList.isEmpty
              ? const Center(child: Text('No chat messages.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chatList.length,
                  itemBuilder: (context, index) {
                    final msg = chatList[index];
                    final isUser = msg.uId == 'user';
                    return Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatTimestamp(msg.timestamp),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          constraints: const BoxConstraints(maxWidth: 250),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.deepOrangeAccent
                                : Colors.amber[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg.content,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
