import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:template/app/api/chat_api.dart';
import 'package:template/app/routing/router_service.dart';
import 'package:template/app/widgets/bottom_navigation_bar.dart';
import 'package:template/app/models/chat_model.dart';
import 'package:template/app/service/audio_service.dart';
import 'package:template/app/service/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  final List<ChatModel> _messages = [];
  late final String _randomImageUrl;
  AnimationController? _controller;
  Animation<double>? _fadeAnimation;
  late final AudioService _audioService;
  late final ChatService _chatService;
  final ScrollController _scrollController = ScrollController();

  String recordingStatus = '🎤 Ready to record...'; // 상태 텍스트

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

    _audioService = AudioService();
    _chatService = ChatService();
    _audioService.requestMicPermission();
    _startVoiceChat();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> playTTS(ChatModel message) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    final chatApi = ChatApi(token);
    final ttsBytes = await chatApi.sendTTSRequest(message.content);

    final player = AudioPlayer();
    await player.play(BytesSource(Uint8List.fromList(ttsBytes)));
  }

  Future<void> _startVoiceChat() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) throw Exception("No token");

      setState(() => recordingStatus = '🎙️ Recording...');
      await _audioService.startRecording();
      await Future.delayed(const Duration(seconds: 5));
      final audioBytes = await _audioService.stopRecordingAndGetBytes();
      setState(() => recordingStatus = '🔊 Sending to server...');

      _chatService.connect(token);
      _chatService.sendAudio(Uint8List.fromList(audioBytes));

      _chatService.listen((reply) {
        setState(() {
          _messages.add(ChatModel(
            uId: 'gemini',
            content: reply,
            timestamp: DateTime.now(),
          ));
          recordingStatus = '✅ Received reply!';
        });
      });
    } catch (e, stack) {
      print("❌ Voice chat error: $e");
      print("🔍 Stack trace: $stack");
      setState(() => recordingStatus = '❌ Error during voice chat');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _audioService.dispose();
    _chatService.close();
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
          if (_fadeAnimation != null)
            FadeTransition(
              opacity: _fadeAnimation!,
              child: Image.network(
                _randomImageUrl,
                height: MediaQuery.of(context).size.height * 0.3,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  color: Colors.grey[300],
                  child:
                      const Center(child: Icon(Icons.broken_image, size: 60)),
                ),
              ),
            ),
          Column(
            children: [
              Lottie.asset('assets/listening-wave.json', height: 60),
              const SizedBox(height: 4),
              Text(
                recordingStatus,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.uId == 'user';
                return Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      TimeOfDay.fromDateTime(message.timestamp).format(context),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      constraints: const BoxConstraints(maxWidth: 250),
                      decoration: BoxDecoration(
                        color:
                            isUser ? Colors.deepOrangeAccent : Colors.amber[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message.content,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
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
