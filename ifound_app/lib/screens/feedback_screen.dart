import 'package:flutter/material.dart';
import 'feedback_wall_screen.dart';

/// Screen for viewing community feedback and adding new feedback.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  @override
  Widget build(BuildContext context) {
    return const CommunityWallScreen();
  }
} 