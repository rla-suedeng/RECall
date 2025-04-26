import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayText =
        "${_weekday(today.weekday)}, ${today.month}/${today.day}/${today.year}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('RECall'),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Good Afternoon, Mary
              const Text(
                'Good Afternoon,\nMary',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                todayText,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Rediscover Memory Banner
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      'https://picsum.photos/400/200', // ✅ 임시 이미지
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      color: Colors.black45,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Rediscover your cherished memories\nthrough conversation',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Mic Button
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.deepOrangeAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.mic,
                            color: Colors.white, size: 32),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Tap to Start Memory Conversation'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Recent Memories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Memories',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(onPressed: () {}, child: const Text('View All')),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _recentMemoryCard('Beach Vacation', 'June 1975'),
                    _recentMemoryCard('Thanksgiving', 'November 1983'),
                    _recentMemoryCard('Wedding', 'May 1965'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Add New Photos
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 32),
                      SizedBox(height: 8),
                      Text('Add New Photos'),
                      Text('Upload from your device',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Memory Albums
              const Text(
                'Memory Albums',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _albumCard('Family', '42 memories', Icons.favorite_border),
                  _albumCard('Travel', '28 memories', Icons.card_travel),
                  _albumCard('Childhood', '19 memories', Icons.child_care),
                  _albumCard(
                      'Special Events', '36 memories', Icons.star_border),
                ],
              ),
              const SizedBox(height: 32),

              // Accessibility
              const Text(
                'Accessibility',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _accessibilitySettings(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.photo_album), label: 'Albums'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  // 요일 텍스트
  String _weekday(int weekday) {
    const week = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return week[(weekday - 1) % 7];
  }

  // Recent Memory Card
  Widget _recentMemoryCard(String title, String date) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(date, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // Album Card
  Widget _albumCard(String title, String subtitle, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Accessibility Settings
  Widget _accessibilitySettings() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              Text('Text Size'),
              Spacer(),
              Icon(Icons.remove),
              SizedBox(width: 8),
              Text('A'),
              SizedBox(width: 8),
              Icon(Icons.add),
            ],
          ),
          Divider(height: 24),
          Row(
            children: [
              Text('High Contrast'),
              Spacer(),
              Switch(value: false, onChanged: null),
            ],
          )
        ],
      ),
    );
  }
}
