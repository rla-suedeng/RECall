import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✅ GoRouter를 사용하는 경우 추가
import 'package:template/app/api/rec_api.dart';
import 'package:template/app/models/rec_model.dart';
import 'package:template/app/models/user_model.dart';
import 'package:template/app/routing/router_service.dart'; // ✅ 라우트 관리용
import 'package:template/app/widgets/bottom_navigation_bar.dart';
import 'package:template/app/service/firebase_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Import FirebaseAuth
import 'package:template/app/theme/colors.dart';
import 'package:template/app/api/user_api.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

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

  String? uploadedImageUrl;

  String? selectedCategory;
  final List<String> categories = [
    'Family',
    'Travel',
    'Childhood',
    'Special',
    'ETC',
  ];

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: AppColors.secondary,
                      style: BorderStyle.solid,
                      width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    if (uploadedImageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: 220,
                          color: Colors.grey[200],
                          child: Image.network(
                            uploadedImageUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.add_photo_alternate_outlined,
                          size: 48, color: AppColors.secondary),
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
                  onPressed: () async {
                    final user = GetIt.I<UserModel>();
                    final userId = user.uId;
                    final idToken =
                        await FirebaseAuth.instance.currentUser?.getIdToken();

                    final formattedDate = dateController.text.isNotEmpty
                        ? dateController.text
                        : DateFormat('yyyy-MM-dd').format(DateTime.now());
                    final content = 'Where: ${whereController.text}\n'
                        'With Whom: ${withWhomController.text}\n'
                        'What Happened: ${whatController.text}\n'
                        'Notes: ${descriptionController.text}';
                    final rec = RecModel(
                      uId: userId,
                      title: titleController.text.trim(),
                      content: content,
                      fileUrl: uploadedImageUrl,
                      date: formattedDate,
                      category: selectedCategory?.toLowerCase() ?? 'etc',
                    );

                    final recApi = RecApi(idToken);
                    final success = await recApi.createRec(rec);

                    if (success) {
                      debugPrint('✅ Rec Save Success');
                      if (context.mounted) {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(Routes.home);
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('❌ Fail to Save')),
                      );
                    }
                    debugPrint('✅ Memory Saved: ${titleController.text}');
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
          onPressed: () async {
            debugPrint('Clicked: $label');

            final firebaseService = FirebaseStorageService();

            try {
              final user = FirebaseAuth.instance.currentUser;
              final userId = user?.uid ?? 'anonymous'; // ✅ 로그인된 유저 ID 사용

              final url =
                  await firebaseService.pickAndUploadImage(userId: userId);

              if (url != null) {
                setState(() {
                  uploadedImageUrl = url;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Image Upload Success')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Cancel Image Select')),
                );
              }
            } catch (e) {
              debugPrint('❌ Image Upload Fail: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error Occur: $e')),
              );
            }
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
        dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }
}
