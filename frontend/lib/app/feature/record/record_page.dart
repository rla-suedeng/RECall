import 'package:flutter/material.dart';
import 'package:template/app/api/rec_api.dart';
import 'package:template/app/models/rec_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:template/app/routing/router_service.dart';
import 'package:template/app/theme/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  Future<void> deleteRec() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final api = RecApi(token);
      await api.deleteRec(widget.recId);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('✅ 기록 삭제 성공')));
        context.go(Routes.album);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ 삭제 실패: $e')));
    }
  }

  void _showEditDialog() {
    final titleController = TextEditingController(text: rec?.title);
    final content = rec?.content ?? '';
    final whereController = TextEditingController(
        text: RegExp(r'Where:\s*(.*)').firstMatch(content)?.group(1) ?? '');
    final withWhomController = TextEditingController(
        text: RegExp(r'With Whom:\s*(.*)').firstMatch(content)?.group(1) ?? '');
    final whatController = TextEditingController(
        text: RegExp(r'What Happened:\s*(.*)').firstMatch(content)?.group(1) ??
            '');
    final noteController = TextEditingController(
        text: RegExp(r'Notes:\s*(.*)').firstMatch(content)?.group(1) ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Memory'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: whereController,
                decoration: const InputDecoration(labelText: 'Where'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: withWhomController,
                decoration: const InputDecoration(labelText: 'With Whom'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: whatController,
                decoration: const InputDecoration(labelText: 'What Happened'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newContent = '''
Where: ${whereController.text.trim()}
With Whom: ${withWhomController.text.trim()}
What Happened: ${whatController.text.trim()}
Notes: ${noteController.text.trim()}''';

              final updatedRec = rec!.copyWith(
                title: titleController.text.trim(),
                content: newContent,
              );

              final token =
                  await FirebaseAuth.instance.currentUser?.getIdToken();
              final api = RecApi(token);
              final result = await api.putRec(widget.recId, updatedRec);

              if (result != null) {
                setState(() => rec = result);
                if (context.mounted) Navigator.pop(context);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('❌ 저장 실패. 다시 시도해주세요.')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (rec == null) return const Center(child: Text('Record not found'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Record'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Record'),
                content:
                    const Text('Are you sure you want to delete this record?'),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                  TextButton(
                    child: const Text('Delete'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      deleteRec();
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (rec!.fileUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: rec!.fileUrl!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            const SizedBox(height: 24),
            const Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(rec!.title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Row(children: [
              const Icon(Icons.category, size: 20),
              const SizedBox(width: 8),
              Text('Category: ${rec!.category}')
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.date_range, size: 20),
              const SizedBox(width: 8),
              Text('Date: ${rec!.date ?? 'Unknown'}')
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.person, size: 20),
              const SizedBox(width: 8),
              Text('Author: ${rec!.authorName ?? 'Unknown'}')
            ]),
            const SizedBox(height: 16),
            const Divider(),
            const Text('Memory Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(rec!.content ?? '-', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('View Related History'),
                onPressed: () {
                  context.go(Routes.history, extra: {'filter': rec!.category});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
