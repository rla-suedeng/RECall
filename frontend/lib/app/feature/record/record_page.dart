import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:template/app/routing/router_service.dart';

class RecordPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const RecordPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final imagePath = data['imagePath'];
    final tag = data['tag'];
    final date = data['date'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Record'),
      ),
      body: Column(
        children: [
          if (imagePath != null)
            Image.asset(imagePath,
                height: 200, width: double.infinity, fit: BoxFit.cover),
          ListTile(
            leading: const Icon(Icons.category),
            title: Text('Category: $tag'),
          ),
          ListTile(
            leading: const Icon(Icons.date_range),
            title: Text('Date: $date'),
          ),
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
                  context.go(Routes.history, extra: {'filter': tag});
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
