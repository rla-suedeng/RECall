import 'package:flutter/material.dart';
import 'package:template/app/theme/colors.dart';
import 'package:template/app/widgets/bottom_navigation_bar.dart';
import 'package:template/app/widgets/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:template/app/models/history_model.dart';
import 'package:template/app/api/history_api.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class ChatHistoryPage extends StatefulWidget {
  final int? recId;
  const ChatHistoryPage({super.key, this.recId});

  @override
  _ChatHistoryPageState createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  late final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchHistory();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<HistoryModel> historyList = [];

  Future<void> fetchHistory() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint("❌ [fetchHistory] Firebase user is null");
      return;
    }

    final token = await user.getIdToken(true);
    debugPrint(
        "🔐 [fetchHistory] Firebase Token (first 20): ${token != null ? token.substring(0, 20) : 'null'}...");

    if (token == null || token.isEmpty) {
      debugPrint("❌ [fetchHistory] Firebase token is empty");
      return;
    }

    final historyApi = HistoryApi(token);

    try {
      final result = widget.recId != null
          ? await historyApi.getHistoryByRecId(widget.recId!)
          : await historyApi.getHistory();

      debugPrint("✅ [fetchHistory] History fetch 성공, count: ${result.length}");

      setState(() {
        historyList = result;
      });
    } catch (e) {
      debugPrint("❌ [fetchHistory] error 발생: $e");
    }
  }

  String formatChatDate(String? rawDate) {
    if (rawDate == null) return 'No date';
    try {
      final parsedDate = DateTime.parse(rawDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final target =
          DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

      if (target == today) return 'Today';
      if (target == yesterday) return 'Yesterday';
      return DateFormat.yMMMMd().format(parsedDate); // e.g. May 4, 2025
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const RECallAppBar(
          title: 'Chat History',
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: Column(
          children: [
            // Chat List
            Expanded(
              child: historyList.isEmpty
                  ? const Center(
                      child: Text(
                        'No History',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 20),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: historyList.length,
                      itemBuilder: (context, index) {
                        final h = historyList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 6),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                                title: Text(formatChatDate(h.date)),
                                subtitle: Text(
                                    h.summary?.toString() ?? 'No Summary',
                                    overflow: TextOverflow.ellipsis),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  context.go('/chat_detail/${h.hId}');
                                }),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          },
          backgroundColor: AppColors.primary,
          child: const Icon(
            Icons.arrow_upward,
            color: AppColors.background,
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(
          currentIndex: 2,
        ));
  }
}
