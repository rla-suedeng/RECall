import 'package:flutter/material.dart';
import 'package:template/app/widgets/bottom_navigation_bar.dart';

class ChatHistoryPage extends StatelessWidget {
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

  ChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chat History',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {},
            ),
          ],
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
          backgroundColor: Colors.orange,
          child: const Icon(Icons.arrow_upward),
        ),
        bottomNavigationBar: const CustomBottomNavBar(
          currentIndex: 2,
        ));
  }
}
