import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:template/app/routing/router_service.dart';

class RecorderRegisterPage extends StatefulWidget {
  const RecorderRegisterPage({super.key});

  @override
  State<RecorderRegisterPage> createState() => _RecorderRegisterPageState();
}

class _RecorderRegisterPageState extends State<RecorderRegisterPage> {
  final reminderEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Reminder\'s Email',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reminderEmailController,
              decoration: const InputDecoration(
                labelText: 'Reminder\'s Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final reminderEmail = reminderEmailController.text.trim();
                  if (reminderEmail.isNotEmpty) {
                    // TODO: 이메일 보내기 로직 추가 예정
                    debugPrint('✅ Reminder 등록 요청 보냄: $reminderEmail');

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Request Sent!'),
                        content:
                            Text('A request has been sent to $reminderEmail'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // 다이얼로그 닫기
                              context.go(Routes.home); // 🔥 HomePage로 이동!
                            },
                            child: const Text('Go to Home'),
                          )
                        ],
                      ),
                    );
                  }
                },
                child: const Text('Send Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
