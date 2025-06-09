import 'package:flutter/material.dart';

class IFoundNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const IFoundNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2196F3),
      unselectedItemColor: Colors.grey[500],
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_rounded),
          label: 'Report Lost',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box_rounded),
          label: 'Report Found',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star_rounded),
          label: 'Feedback',
        ),
      ],
      backgroundColor: Colors.white,
      elevation: 12,
    );
  }
} 