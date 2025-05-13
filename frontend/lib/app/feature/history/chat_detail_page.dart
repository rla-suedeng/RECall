import 'package:flutter/material.dart';
import 'package:template/app/models/chat_model.dart';
import 'package:template/app/api/chat_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:template/app/routing/router_service.dart';
import 'package:go_router/go_router.dart';

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
      appBar: AppBar(
        title: const Text('Chat Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Future.delayed(const Duration(milliseconds: 100), () {
              context.go(Routes.history);
            });
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatList.isEmpty
              ? const Center(child: Text('No chat messages.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chatList.length,
                  itemBuilder: (context, index) {
                    final msg = chatList[index];
                    final isGemini = msg.uId.trim().toLowerCase() == 'gemini';
                    return Column(
                      crossAxisAlignment: isGemini
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
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
                              color: isGemini
                                  ? Colors.white
                                  : Colors.deepOrangeAccent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isGemini
                                  ? [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(2, 2),
                                      )
                                    ]
                                  : []),
                          child: Text(
                            msg.content,
                            style: TextStyle(
                              color: isGemini ? Colors.black87 : Colors.white,
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
