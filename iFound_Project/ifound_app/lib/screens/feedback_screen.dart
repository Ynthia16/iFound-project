import 'package:flutter/material.dart';
import '../components/ifound_appbar.dart';
import '../components/ifound_stars.dart';
import '../components/ifound_textfield.dart';
import '../components/ifound_button.dart';
import '../components/ifound_background.dart';
import 'feedback_wall_screen.dart';

/// Screen for submitting feedback with a star rating and comment.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int rating = 0;
  final commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return IFoundBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const IFoundAppBar(title: 'Feedback'),
        body: Center(
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 32),
                      SizedBox(width: 12),
                      Text(
                        'Feedback',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'How was your experience?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2196F3)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  IFoundStars(
                    rating: rating,
                    onChanged: (val) => setState(() => rating = val),
                  ),
                  const SizedBox(height: 24),
                  IFoundTextField(
                    label: 'Leave a comment (optional)',
                    controller: commentController,
                  ),
                  const SizedBox(height: 32),
                  IFoundButton(
                    text: 'Submit Feedback',
                    onPressed: rating == 0
                        ? null
                        : () async {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Thank you!'),
                                content: const Text('Your feedback has been submitted.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            await Future.delayed(const Duration(milliseconds: 800));
                            if (context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const FeedbackWallScreen()),
                              );
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 