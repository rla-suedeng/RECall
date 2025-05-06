import 'package:flutter/material.dart';
import 'package:template/app/theme/colors.dart';
//import 'package:go_router/go_router.dart';
//import 'package:template/app/routing/router_service.dart';
import 'package:template/app/widgets/bottom_navigation_bar.dart';
import 'package:template/app/widgets/app_bar.dart';

class ProfilePage extends StatelessWidget {
  final String name = "Thomas Anderson";
  final int age = 32;
  final String userType = "Recorder";
  final String email = "thomas.anderson@example.com";
  final String phone = "+1 (555) 123-4567";

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E6),
      appBar: const RECallAppBar(
        title: '',
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 24,
            ),
            // Profile Info
            Row(
              children: [
                CircleAvatar(radius: 32, backgroundColor: Colors.grey.shade300),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('$age years old',
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.deepOrangeAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(userType,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Contact Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(children: [
                    const Icon(Icons.email, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(email),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.phone, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(phone),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Accessibility
            const Text("Accessibility",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Text Size", style: TextStyle(fontSize: 16)),
                    Row(children: [
                      IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {/* reduce font size */}),
                      const Text("100%", style: TextStyle(fontSize: 16)),
                      IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {/* increase font size */}),
                    ]),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("High Contrast", style: TextStyle(fontSize: 16)),
                    Switch(
                        value: false, onChanged: (val) {/* toggle contrast */}),
                  ],
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // Support
            const Text("Support",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text("Help Center"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: const Text("Contact Support"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text("About"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // Logout
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Log Out",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.background)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}
