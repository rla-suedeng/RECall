import 'package:flutter/material.dart';
import 'package:template/app/theme/colors.dart';
import 'package:template/app/widgets/bottom_navigation_bar.dart';
import 'package:template/app/widgets/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:template/app/models/history_model.dart';
import 'package:template/app/api/history_api.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  _ChatHistoryPageState createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  final List<Map<String, String>> chatData = [
    {
      "date": "Today",
      "summary":
          "Planning for the summer vacation. Let's discuss the details..."
    },
    {
      "date": "Yesterday",
      "summary": "Project meeting summary and next steps..."
    },
    {
      "date": "May 4, 2025",
      "summary": "Weekly team updates and progress report..."
    },
    {
      "date": "May 3, 2025",
      "summary": "Client feedback on the new design proposal..."
    },
    {
      "date": "May 2, 2025",
      "summary": "Birthday party planning and guest list..."
    },
    {
      "date": "May 1, 2025",
      "summary": "Monthly review meeting notes and action items..."
    },
  ];

  List<HistoryModel> historyList = [];

  Future<void> fetchHistory() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final historyApi = HistoryApi(token);
    final result = await historyApi.getHistory();
    setState(() {
      historyList = result;
    });
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
              child: ListView.builder(
                itemCount: chatData.length,
                itemBuilder: (context, index) {
                  final item = chatData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 6),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(item['date']!),
                        subtitle: Text(item['summary']!,
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
            // Scroll to top or another action
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
