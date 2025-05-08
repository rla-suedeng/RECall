import 'package:flutter/material.dart';
import 'package:template/app/api/rec_api.dart';
import 'package:template/app/models/rec_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:template/app/routing/router_service.dart';

class RecordPage extends StatefulWidget {
  final int recId;

  const RecordPage({super.key, required this.recId});
  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  RecModel? rec;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecDetail();
  }

  Future<void> fetchRecDetail() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final api = RecApi(token);
      final result = await api.getRec(widget.recId);
      setState(() {
        rec = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Rec Detail 불러오기 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // final imagePath = data['imagePath'];
    // final tag = data['tag'];
    // final date = data['date'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Record'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if (imagePath != null)
          //   Image.asset(imagePath,
          //       height: 200, width: double.infinity, fit: BoxFit.cover),
          if (rec!.fileUrl != null)
            Image.network(
              rec!.fileUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image)),
            ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.category),
            title: Text('Category: ${rec!.category}'),
          ),
          ListTile(
            leading: const Icon(Icons.date_range),
            title: Text('Date: ${rec!.date ?? 'Unknown'}'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('Author: ${rec!.author ?? 'Unknown'}'),
          ),
          if (rec!.content != null) ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Memory Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(rec!.content!),
            ),
          ],
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('View Related Chat'),
                onPressed: () {
                  context.go(Routes.history, extra: {'filter': rec!.category});
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
