import 'package:flutter/material.dart';
import 'package:template/app/theme/colors.dart';
import 'package:template/app/widgets/app_bar.dart';
import 'package:template/app/widgets/bottom_navigation_bar.dart';
import 'package:template/app/routing/router_service.dart';
import 'package:go_router/go_router.dart';
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
                    Navigator.pop(context);
                    context.go(Routes.home);
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
      );
      setState(() {
        allRecs = recs;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching recs: $e");
    }
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Container(
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
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down),
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Icon(icon, size: 18, color: Colors.deepOrange),
                  const SizedBox(width: 8),
                  Flexible(child: Text(item, overflow: TextOverflow.ellipsis)),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
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

          /// Dropdown filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    value: selectedCategory,
                    items: categoryOptions,
                    icon: Icons.filter_alt,
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
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdown(
                    value: selectedSort,
                    items: ['Newest First', 'Oldest First'],
                    icon: Icons.calendar_today,
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
                onChanged: (val) => setState(() => keyword = val),
                onSubmitted: (_) => getRecs(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// 사진 그리드
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : allRecs.isEmpty
                    ? const Center(
                        child: Text(
                          'No results found.',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
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
                          return GestureDetector(
                            onTap: () {
                              context.pushNamed(
                                Routes.record,
                                pathParameters: {'id': rec.rId ?? ''},
                              );
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
