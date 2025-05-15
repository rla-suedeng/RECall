import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:template/app/api/chat_api.dart';
import 'package:template/app/routing/router_service.dart';
import 'package:template/app/theme/colors.dart';
import 'package:template/app/widgets/bottom_navigation_bar.dart';
import 'package:template/app/models/chat_model.dart';
import 'package:template/app/service/audio_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';

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

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final List<ChatModel> _messages = [];
  String? _imageUrl;
  AnimationController? _controller;
  AnimationController? _lottieController;
  Animation<double>? _fadeAnimation;
  late final AudioService _audioService;
  final ScrollController _scrollController = ScrollController();
  late final AudioPlayer _player;
  int? _hId;
  String recordingStatus = '🎤 Ready to record...';
  bool initialTextLoaded = false;
  bool isRecording = false;

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

    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _player = AudioPlayer();
    _audioService = AudioService();
    _audioService.requestMicPermission();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadChatHistory();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool isSameMessage(ChatModel m, String initialText) {
    return m.uId == 'gemini' && m.content.trim() == initialText.trim();
  }

  Future<void> _loadChatHistory() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) throw Exception("No token");

      final chatApi = ChatApi(token);
      final (statusCode, data) = await chatApi.enterChat();
      if (statusCode == 403) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ No permission to enter")),
          );
          context.go(Routes.home);
        }
        return;
      }
      if (statusCode == 404) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Need Memory Record")),
          );
          context.go(Routes.home);
        }
        return;
      }
      if (statusCode != 200 || data == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("⚠️ Error Occur: $statusCode")),
          );
          context.go(Routes.home);
        }
        return;
      }

      _hId = data['h_id'];
      final initialText = data['initial_text'];
      final base64Audio = data['audio_base64'];
      _imageUrl = extractOriginalImageUrl(data['rec_file']);

      final historyList = await chatApi.getChatHistory(historyId: _hId!);
      final createdAt = DateTime.tryParse(data['timestamp'] ?? '')?.toUtc();
      final alreadyExists = initialText != null &&
          historyList.any((m) => isSameMessage(m, initialText));

      final audioBytes =
          base64Audio != null ? chatApi.decodeAudioBase64(base64Audio) : null;

      setState(() {
        _messages.clear();
        _messages.addAll(historyList);

        if (initialText != null && !alreadyExists) {
          _messages.add(ChatModel(
            uId: 'gemini',
            content: initialText,
            timestamp: createdAt ?? DateTime.now().toUtc(),
          ));
        }

        if (initialText != null || _messages.any((m) => m.uId == 'gemini')) {
          initialTextLoaded = true;
        }
      });

      if (audioBytes != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _audioService.playAudioBytes(audioBytes);
        });
      }

      _controller?.forward();
      _scrollToBottom();
    } catch (e) {
      print("❌ Fail initiate: $e");
    }
  }

  Future<void> startRecording() async {
    setState(() => recordingStatus = '🎙️ Recording...');
    _lottieController?.repeat();
    await _audioService.startRecording();
    setState(() => isRecording = true);

    Future.delayed(const Duration(seconds: 5), () {
      if (isRecording) stopRecordingAndSend();
    });
  }

  Future<void> stopRecordingAndSend() async {
    final audioBytes = await _audioService.stopRecordingAndGetBytes();
    setState(() {
      recordingStatus = '💬 Getting message from Gemini...';
      isRecording = false;
    });
    _lottieController?.stop();
    await _sendToGemini(audioBytes);
  }

  Future<void> _sendToGemini(List<int> audioBytes) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null || _hId == null) throw Exception("No token or chat id");

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
            timestamp: DateTime.now().toUtc(),
          ));
        }
        if (responseText != null) {
          _messages.add(ChatModel(
            uId: 'gemini',
            content: responseText,
            timestamp: DateTime.now().toUtc(),
          ));
        }
        recordingStatus = '✅ Reply received!';
      });

      if (responseAudioBase64 != null) {
        final responseAudio = chatApi.decodeAudioBase64(responseAudioBase64);
        await _audioService.playAudioBytes(responseAudio);
      }

      _scrollToBottom();

      if ((responseText?.toLowerCase().contains("peaceful and joyful day") ??
          false)) {
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) context.go(Routes.home);
        });
      }
    } catch (e) {
      print("❌ Error : $e");
      setState(() => recordingStatus = '❌ Error occurred');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _lottieController?.dispose();
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
              Lottie.asset(
                'assets/listening-wave.json',
                height: 60,
                controller: _lottieController,
                onLoaded: (composition) {
                  _lottieController?.duration = composition.duration;
                },
              ),
              const SizedBox(height: 4),
              Text(recordingStatus,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey)),
              const SizedBox(height: 8),
              const Text("👋 Say 'Good bye' to finish the conversation.",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
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
                final isGemini = msg.uId == 'gemini';
                return Column(
                  crossAxisAlignment: isGemini
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
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
                            isGemini ? Colors.white : Colors.deepOrangeAccent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isGemini
                            ? [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                )
                              ]
                            : [],
                      ),
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
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!initialTextLoaded)
            const Text(
              'Loading Memory...',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          const SizedBox(height: 4),
          GestureDetector(
            onLongPressStart:
                initialTextLoaded ? (_) async => await startRecording() : null,
            onLongPressEnd: initialTextLoaded
                ? (_) async => await stopRecordingAndSend()
                : null,
            child: Opacity(
              opacity: initialTextLoaded ? 1.0 : 0.5,
              child: FloatingActionButton(
                backgroundColor: initialTextLoaded
                    ? (isRecording ? Colors.red : AppColors.secondary)
                    : Colors.grey.shade400,
                onPressed: null,
                child: Icon(Icons.mic,
                    color: initialTextLoaded
                        ? Colors.grey.shade200
                        : Colors.white),
              ),
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
