import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:template/app/api/chat_api.dart';
import 'package:template/app/routing/router_service.dart';
import 'package:template/app/widgets/bottom_navigation_bar.dart';
import 'package:template/app/models/chat_model.dart';
import 'package:template/app/service/audio_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

String extractOriginalImageUrl(String proxyUrl) {
  final uri = Uri.parse(proxyUrl);
  final srcParam = uri.queryParameters['src'];
  if (srcParam != null && srcParam.isNotEmpty) {
    return Uri.decodeFull(srcParam);
  }
  return proxyUrl;
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  final List<ChatModel> _messages = [];
  String? _imageUrl;
  AnimationController? _controller;
  Animation<double>? _fadeAnimation;
  late final AudioService _audioService;
  final ScrollController _scrollController = ScrollController();
  late final AudioPlayer _player;
  int? _hId;
  String recordingStatus = '🎤 Ready to record...';

  @override
  void initState() {
    super.initState();
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

    _player = AudioPlayer();
    _audioService = AudioService();
    _startChatSession();
    _audioService.requestMicPermission();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _playAudio(Uint8List audioBytes) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_audio.mp3');
    await tempFile.writeAsBytes(audioBytes);

    await _player.stop();
    await _player.setFilePath(tempFile.path);
    await _player.setVolume(1.0);
    await _player.play();
  }

  Future<void> _startChatSession() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) throw Exception("No token");

      final chatApi = ChatApi(token);
      final data = await chatApi.enterChat();
      _hId = data['h_id'];
      final initialText = data['initial_text'];
      final base64Audio = data['audio_base64'];
      _imageUrl = extractOriginalImageUrl(data['rec_file']);

      if (initialText != null) {
        setState(() {
          _messages.add(ChatModel(
            uId: 'gemini',
            content: initialText,
            timestamp: DateTime.now(),
          ));
        });
        if (base64Audio != null) {
          final audioBytes = chatApi.decodeAudioBase64(base64Audio);
          await _playAudio(audioBytes);
        }
        _scrollToBottom();
      }
    } catch (e) {
      print("❌ 초기 대화 시작 실패: $e");
    }
  }

  Future<void> _startVoiceChat() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null || _hId == null) throw Exception("No token or chat id");

      setState(() => recordingStatus = '🎙️ Recording...');
      await _audioService.startRecording();
      await Future.delayed(const Duration(seconds: 5));
      final audioBytes = await _audioService.stopRecordingAndGetBytes();
      setState(() => recordingStatus = '💬 Sending audio to server...');

      final chatApi = ChatApi(token);

      final result = await chatApi.sendMessageWithAudio(
        token: token,
        hId: _hId!,
        audioBytes: Uint8List.fromList(audioBytes),
      );

      final userText = result['user_text'];
      final responseText = result['text'];
      final responseAudioBase64 = result['audio_base64'];

      setState(() {
        if (userText != null) {
          _messages.add(ChatModel(
            uId: 'user',
            content: userText,
            timestamp: DateTime.now(),
          ));
        }
        if (responseText != null) {
          _messages.add(ChatModel(
            uId: 'gemini',
            content: responseText,
            timestamp: DateTime.now(),
          ));
        }
        recordingStatus = '✅ Reply received!';
      });

      if (responseAudioBase64 != null) {
        final responseAudio = chatApi.decodeAudioBase64(responseAudioBase64);
        await _playAudio(responseAudio);
      }

      if ((responseText?.toLowerCase().contains("peaceful and joyful day") ??
          false)) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.go(Routes.home);
        });
      }

      _scrollToBottom();
    } catch (e) {
      print("❌ 오류 발생: $e");
      setState(() => recordingStatus = '❌ Error occurred');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _audioService.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.home),
        ),
      ),
      body: Column(
        children: [
          if (_fadeAnimation != null && _imageUrl != null)
            FadeTransition(
              opacity: _fadeAnimation!,
              child: Image.network(
                _imageUrl!,
                height: MediaQuery.of(context).size.height * 0.3,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('❌ 이미지 로딩 실패: $error');
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    color: Colors.grey[300],
                    child:
                        const Center(child: Icon(Icons.broken_image, size: 60)),
                  );
                },
              ),
            ),
          Column(
            children: [
              Lottie.asset('assets/listening-wave.json', height: 60),
              const SizedBox(height: 4),
              Text(recordingStatus,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey)),
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
                final msg = _messages[index];
                final isUser = msg.uId == 'user';
                return Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      TimeOfDay.fromDateTime(msg.timestamp).format(context),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startVoiceChat,
        child: const Icon(Icons.mic),
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: null,
        highlight: false,
      ),
    );
  }
}
