import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // GoRouter 사용 시
import 'package:template/app/widgets/bottom_navigation_bar.dart';
import 'package:template/app/routing/router_service.dart';

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  String selectedCategory = 'All Categories';
  String selectedSort = 'Newest First';

  final List<String> dummyImages = List.generate(
    12,
    (index) => 'assets/images/dummy${(index % 5) + 1}.jpg',
  );

  final List<Map<String, String>> photos = List.generate(18, (index) {
    return {
      'date': '2025-05-${(index % 30) + 1}',
      'category': ['Family', 'Travel', 'Events', 'Childhood'][index % 4],
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
      appBar: AppBar(
        title: const Text('Photos'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
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
                          'Events'
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
                            setState(() => selectedCategory = val);
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
                            setState(() => selectedSort = val);
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
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search photos...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// 사진 그리드
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: filteredPhotos.length,
              itemBuilder: (context, index) {
                final photo = filteredPhotos[index];
                final imagePath = dummyImages[index % dummyImages.length];

                return GestureDetector(
                  onTap: () {
                    context.push(Routes.record, extra: {
                      'imagePath': imagePath,
                      'date': photo['date'],
                      'category': photo['category'],
                    });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
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
