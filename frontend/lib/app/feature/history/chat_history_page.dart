import 'package:flutter/material.dart';
import 'package:template/app/theme/colors.dart';
import 'package:template/app/widgets/bottom_navigation_bar.dart';
import 'package:template/app/widgets/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:template/app/models/history_model.dart';
import 'package:template/app/api/history_api.dart';
import 'package:intl/intl.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  _ChatHistoryPageState createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  late final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<HistoryModel> historyList = [];

  Future<void> fetchHistory() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final historyApi = HistoryApi(token);
    final result = await historyApi.getHistory();
    print("🟢 받은 history 데이터: $result");
    setState(() {
      historyList = result;
    });
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
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by date or message content...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),
            ),
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
                              onTap: () {},
                            ),
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
