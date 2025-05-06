import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✅ GoRouter를 사용하는 경우 추가
import 'package:template/app/routing/router_service.dart'; // ✅ 라우트 관리용
import 'package:template/app/widgets/bottom_navigation_bar.dart';

class AddRecordPage extends StatefulWidget {
  const AddRecordPage({super.key});

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();

  final whereController = TextEditingController();
  final withWhomController = TextEditingController();
  final whatController = TextEditingController();

  String? selectedCategory;
  final List<String> categories = [
    'Family',
    'Travel',
    'Childhood',
    'Special Events',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add New Record'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go(Routes.home);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지 업로드 영역
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(
                      color: Colors.grey[300]!,
                      style: BorderStyle.solid,
                      width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.add_photo_alternate_outlined,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('Drag photos here or choose from:'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _uploadOption(Icons.camera_alt_outlined, 'Camera'),
                        _uploadOption(Icons.photo_outlined, 'Gallery'),
                        _uploadOption(Icons.cloud_upload_outlined, 'Cloud'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Memory Title
              const Text('Memory Title'),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter a title for this memory',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Date
              const Text('Date'),
              const SizedBox(height: 8),
              TextField(
                controller: dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  hintText: '-/-/-',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Album Category
              const Text('Album Category'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                decoration: const InputDecoration(
                  hintText: 'Select a category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              // 기존 "Description" 섹션 아래 교체
              const Text('Where'),
              const SizedBox(height: 8),
              TextField(
                controller: whereController,
                decoration: const InputDecoration(
                  hintText: 'Where did it happen?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              const Text('With Whom'),
              const SizedBox(height: 8),
              TextField(
                controller: withWhomController,
                decoration: const InputDecoration(
                  hintText: 'Who were you with?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              const Text('What Happened'),
              const SizedBox(height: 8),
              TextField(
                controller: whatController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Briefly describe what happened',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              const Text('Additional Notes (optional)'),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add any extra details about this memory...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Save Memory'),
                  onPressed: () {
                    debugPrint('✅ Memory Saved: ${titleController.text}');
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(
          highlight: false,
          currentIndex: null,
        ));
  }

  Widget _uploadOption(IconData icon, String label) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 32),
          onPressed: () {
            debugPrint('Clicked: $label');
          },
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        dateController.text =
            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
      });
    }
  }
}
