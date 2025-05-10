import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // GoRouter 사용 시
import 'package:template/app/theme/colors.dart';
import 'package:template/app/widgets/app_bar.dart';
import 'package:template/app/widgets/bottom_navigation_bar.dart';
import 'package:template/app/routing/router_service.dart';
import 'package:template/app/models/rec_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:template/app/api/rec_api.dart';
import 'package:template/app/models/user_model.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AlbumPage extends StatefulWidget {
  final String? initialCategory;
  const AlbumPage({super.key, this.initialCategory = 'All Categories'});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  late String? selectedCategory;
  String selectedSort = 'Newest First';
  String keyword = '';
  List<RecModel> allRecs = [];
  bool isLoading = true;
  List<RecModel> filteredRecs = [];

  final List<String> categoryOptions = [
    'All Categories',
    'Family',
    'Travel',
    'Childhood',
    'Special',
    'Etc',
  ];

  String _capitalize(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    final normalized = _capitalize(widget.initialCategory?.toLowerCase() ?? '');

    selectedCategory =
        categoryOptions.contains(normalized) ? normalized : 'All Categories';

    getRecs();
  }

  Future<void> getRecs() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) throw Exception("No token");
      final recApi = RecApi(token);
      final user = GetIt.I<UserModel>();
      final filteredCategory = (selectedCategory != 'All Categories')
          ? selectedCategory?.toLowerCase()
          : null;
      final order = selectedSort == 'Newest First' ? 'desc' : 'asc';
      if (!user.role) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Access Denied'),
              content: const Text('Only reminders can access memory albums.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 팝업 닫기
                    context.go(Routes.home); // 홈으로 이동
                  },
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          );
        }
        return;
      }
      final recs = await recApi.getRecs(
        category: filteredCategory,
        keyword: keyword,
        order: order,
      ); // 정상 호출
      setState(() {
        allRecs = recs;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching recs: $e");
    }
  }

  Future<void> fetchFilteredRecs() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final recApi = RecApi(token);
    final result = await recApi.getRecs(category: selectedCategory);
    setState(() {
      filteredRecs = result;
    });
  }

  // final List<String> dummyImages = List.generate(
  //   12,
  //   (index) => 'assets/images/dummy${(index % 5) + 1}.jpg',
  // );

  final List<Map<String, String>> photos = List.generate(18, (index) {
    return {
      'date': '2025-05-${(index % 30) + 1}',
      'category': ['family', 'Travel', 'Special', 'Childhood'][index % 4],
    };
  });

  List<Map<String, String>> get filteredPhotos {
    return photos.where((photo) {
      return selectedCategory == 'All Categories' ||
          photo['category'] == selectedCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RECallAppBar(
        title: 'Album',
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          /// 필터 드롭다운 2개
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        isExpanded: true,
                        items: [
                          'All Categories',
                          'Family',
                          'Travel',
                          'Childhood',
                          'Special',
                          'Etc'
                        ].map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Row(
                              children: [
                                const Icon(Icons.filter_alt,
                                    size: 18, color: Colors.deepOrange),
                                const SizedBox(width: 8),
                                Text(cat),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedCategory = val;
                              isLoading = true;
                            });
                            getRecs();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSort,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        isExpanded: true,
                        items: ['Newest First', 'Oldest First'].map((sort) {
                          return DropdownMenuItem(
                            value: sort,
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 18, color: Colors.deepOrange),
                                const SizedBox(width: 8),
                                Text(sort),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedSort = val;
                              isLoading = true;
                            });
                            getRecs();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// 검색창
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search photos...',
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() => keyword = val);
                },
                onSubmitted: (_) => getRecs(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// 사진 그리드
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : allRecs.isEmpty
                    ? const Center(
                        child: Text(
                        'No results found.',
                        style: TextStyle(
                            fontSize: 20, color: AppColors.textSecondary),
                      ))
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: allRecs.length,
                        itemBuilder: (context, index) {
                          final rec = allRecs[index];
                          //final photo = filteredPhotos[index];
                          //final imagePath = dummyImages[index % dummyImages.length];

                          return GestureDetector(
                            onTap: () {
                              context.pushNamed(
                                Routes.record,
                                pathParameters: {'id': rec.rId ?? ''},
                              );
                              {
                                //'imagePath': imagePath,
                                // 'date': photo['date'],
                                // 'category': photo['category'],
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: rec.fileUrl ?? '',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Center(
                                        child: Icon(Icons.broken_image)),
                              ),
                              // child: Image.asset(
                              //   imagePath,
                              //   fit: BoxFit.cover,
                              // ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
