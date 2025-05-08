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

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
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

  late final String _randomImageUrl;
  AnimationController? _controller;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _randomImageUrl = 'https://picsum.photos/400/200';

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeIn,
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _controller?.forward();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

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
          // 상단 이미지 (회상 이미지)
          if (_fadeAnimation != null)
            FadeTransition(
              opacity: _fadeAnimation!,
              child: Image.network(
                'https://picsum.photos/400/200',
                height: MediaQuery.of(context).size.height * 0.3,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 60),
                    ),
                  );
                },
              ),
            ),

          // 애니메이션 + Listening 텍스트
          Column(
            children: [
              Lottie.asset(
                'assets/listening-wave.json',
                height: 60,
              ),
              const SizedBox(height: 4),
              const Text(
                'Listening to your memory...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
            ],
          ),

          const Divider(height: 1),

          // 채팅 메시지 영역
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
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: null,
        highlight: false,
      ),
    );
  }
}
