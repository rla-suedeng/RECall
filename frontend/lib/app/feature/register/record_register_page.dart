import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:template/app/routing/router_service.dart';
import 'package:template/app/api/user_api.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth에서 토큰 가져오기
import 'package:template/app/api/dio_client.dart';
import 'package:dio/dio.dart'; // Import Dio package

class RecorderRegisterPage extends StatefulWidget {
  const RecorderRegisterPage({super.key});

  @override
  State<RecorderRegisterPage> createState() => _RecorderRegisterPageState();
}

class _RecorderRegisterPageState extends State<RecorderRegisterPage> {
  final reminderEmailController = TextEditingController();
  bool isLoading = false;

  Future<void> sendApplyRequest() async {
    final reminderEmail = reminderEmailController.text.trim();
    if (reminderEmail.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) throw Exception("No ID Token found");

      final dio = Dio(); // Create a Dio instance
      final myDio = MyDio(dio: dio);
      final userApi = UserApi(myDio);
      await userApi.applyPatient(
        email: reminderEmail,
        idToken: idToken,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Request Sent!'),
          content: Text('A request has been sent to $reminderEmail'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go(Routes.home);
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('❌ 신청 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('신청 실패: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Reminder'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Future.delayed(const Duration(milliseconds: 100), () {
              context.go(Routes.home);
            });
          },
        ),
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
                onPressed: isLoading ? null : sendApplyRequest,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
