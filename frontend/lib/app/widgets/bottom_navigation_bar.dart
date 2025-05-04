import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:template/app/routing/router_service.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int? currentIndex;
  final bool highlight;

  const CustomBottomNavBar(
      {super.key, required this.currentIndex, this.highlight = true});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.home);
        break;
      case 1:
        context.go(Routes.error);
        break;
      case 2:
        context.go(Routes.chat);
        break;
      case 3:
        context.go(Routes.login);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex ?? 0,
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: Colors.deepOrange,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.photo_album), label: 'Photos'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
