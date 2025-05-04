import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:template/app/routing/router_service.dart';
import 'package:template/app/widgets/bottom_navigation_bar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text':
          "Hello Mary! It's wonderful to chat with you today. Would you like to tell me about your favorite childhood memory?",
      'time': "2:45 PM"
    },
    {
      'isUser': true,
      'text':
          "I remember going to the beach with my family when I was young. We used to build sandcastles together.",
      'time': "2:46 PM"
    },
    {
      'isUser': false,
      'text':
          "That sounds like a wonderful memory, Mary! Can you tell me more about those beach trips? What was your favorite part?",
      'time': "2:47 PM"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(Routes.home);
          },
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // 캐릭터 애니메이션
          Lottie.asset(
            'assets/speaker_animation.json',
            height: 120,
          ),
          const SizedBox(height: 16),

          // Listening + Mic
          const Text('Listening...', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.deepOrangeAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.mic, color: Colors.white),
              onPressed: () {
                // TODO: 음성 인식 기능 연결
              },
            ),
          ),
          const SizedBox(height: 8),
          const Text('Tap to speak'),
          const SizedBox(height: 16),

          const Divider(),

          // 채팅 메시지
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Column(
                  crossAxisAlignment: message['isUser']
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      message['time'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      constraints: const BoxConstraints(maxWidth: 250),
                      decoration: BoxDecoration(
                        color: message['isUser']
                            ? Colors.deepOrangeAccent
                            : Colors.amber[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message['text'],
                        style: TextStyle(
                          color:
                              message['isUser'] ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
