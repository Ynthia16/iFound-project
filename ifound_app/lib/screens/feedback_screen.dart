import 'package:flutter/material.dart';
import '../components/ifound_appbar.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const IFoundAppBar(
        title: 'Community',
        showLogo: true,
      ),
      body: const CommunityWallScreen(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to the community wall which has the add feedback functionality
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CommunityWallScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.rate_review),
        label: const Text('Add Feedback'),
        elevation: 4,
      ),
    );
  }
} 