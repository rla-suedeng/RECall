import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:template/app/api/home_api.dart';
import 'package:template/app/routing/router_service.dart';
import 'package:template/app/widgets/bottom_navigation_bar.dart';
import 'package:template/app/theme/colors.dart';
import 'package:template/app/widgets/app_bar.dart';
import 'package:template/app/models/user_model.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:template/app/models/rec_model.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:template/app/state/accessibility_settings.dart';

String formatMonthYear(String? dateStr) {
  if (dateStr == null) return 'Unknown';
  try {
    final parsed = DateFormat('yyyy-MM-dd').parse(dateStr);
    return DateFormat('MMMM yyyy').format(parsed);
  } catch (_) {
    return 'Invalid date';
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static bool _popupShown = false;
  UserModel? user;
  bool isLoading = true;

  String userName = 'User';
  List<RecModel> recentRecs = [];
  Map<String, int> categoryCounts = {};

  @override
  void initState() {
    super.initState();
    fetchHomeInfo();
    final getIt = GetIt.I;
    if (getIt.isRegistered<UserModel>()) {
      user = GetIt.I<UserModel>();
    }
    isLoading = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_popupShown && (user?.role == true)) {
        _showWelcomePopup(context);
        _popupShown = true;
      }
    });
  }

  Future<void> fetchHomeInfo() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final homeApi = HomeApi(token);
      final data = await homeApi.getHomeInfo();

      final String name = data['name'] ?? 'User';
      final List<dynamic> recent = data['recent_memory'] ?? [];
      final Map<String, dynamic> counts =
          Map<String, dynamic>.from(data['num_rec'] ?? {});

      setState(() {
        userName = name;
        recentRecs = recent.map((e) => RecModel.fromJson(e)).toList();
        categoryCounts =
            counts.map((k, v) => MapEntry(k.toLowerCase(), v as int));
      });
    } catch (e) {
      print("❌ Fail loading Home Info: $e");
      setState(() {
        userName = 'User';
        recentRecs = [];
        categoryCounts = {};
      });
    }
  }

  void _showWelcomePopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    'assets/robot.png',
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ready to revisit your memories?\nI\'m here to help!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.mic, color: Colors.white),
                    label: const Text('Talk to Me',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      Navigator.pop(context);
                      context.go(Routes.chat);
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayText =
        "${_weekday(today.weekday)}, ${today.month}/${today.day}/${today.year}";

    return Scaffold(
      appBar: const RECallAppBar(
        title: 'RECall',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLoading
                    ? 'Good Afternoon,\n...'
                    : 'Good Afternoon, \n${userName ?? 'User'}',
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                todayText,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      'https://picsum.photos/400/200',
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
                        onPressed: () {
                          context.go(Routes.chat);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Tap to Start Memory Conversation'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Memories',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                      onPressed: () {
                        context.go(Routes.album);
                      },
                      child: const Text('View All')),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentRecs.length,
                  itemBuilder: (context, index) {
                    return _recentMemoryCard(recentRecs[index]);
                  },
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  context.go(Routes.addRecord);
                },
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
              const Text(
                'Memory Albums',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaler: const TextScaler.linear(1.0)),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _albumCard('family', Icons.favorite_border),
                            _albumCard('travel', Icons.card_travel),
                            _albumCard('childhood', Icons.child_care),
                            _albumCard('special', Icons.star_border),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 32),
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
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
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
  Widget _recentMemoryCard(RecModel rec) {
    final title = rec.title;
    final date = rec.date != null
        ? DateFormat.yMMMM().format(DateTime.parse(rec.date!))
        : 'Unknown';
    final imageUrl = rec.fileUrl;

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: imageUrl ?? '',
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 80,
                  color: Colors.grey[200],
                ),
                errorWidget: (context, url, error) => Container(
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 24),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Album Card
  Widget _albumCard(String category, IconData icon) {
    final count = categoryCounts[category.toLowerCase()] ?? 0;
    final title = category;
    final subtitle = '$count memories';

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          Routes.album,
          queryParameters: {'category': category.toLowerCase()},
        );
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.softBlue,
              ),
              child: Icon(
                icon,
                size: 28,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Accessibility Settings
  Widget _accessibilitySettings() {
    return ValueListenableBuilder<double>(
      valueListenable: AccessibilitySettings.textScaleFactor,
      builder: (context, scale, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: AccessibilitySettings.highContrast,
          builder: (context, highContrast, _) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: highContrast ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Text Size", style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              final current =
                                  AccessibilitySettings.textScaleFactor.value;
                              if (current > 0.8) {
                                AccessibilitySettings.textScaleFactor.value =
                                    (current - 0.1).clamp(0.8, 2.0);
                              }
                            },
                          ),
                          Text("${(scale * 100).round()}%",
                              style: const TextStyle(fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              final current =
                                  AccessibilitySettings.textScaleFactor.value;
                              if (current < 2.0) {
                                AccessibilitySettings.textScaleFactor.value =
                                    (current + 0.1).clamp(0.8, 2.0);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
