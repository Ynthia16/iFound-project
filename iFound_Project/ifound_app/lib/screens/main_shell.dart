import 'package:flutter/material.dart';
import '../components/ifound_navbar.dart';
import 'home_screen.dart';
import 'report_lost_screen.dart';
import 'report_found_screen.dart';
import 'feedback_screen.dart';
import 'package:provider/provider.dart';
import '../main.dart';

/// Main navigation shell with bottom navigation bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onTabSelected: goToTab),
      const ReportLostScreen(),
      const ReportFoundScreen(),
      const FeedbackScreen(),
    ];
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: IFoundNavBar(
        currentIndex: _currentIndex,
        onTap: goToTab,
      ),
    );
  }
} 