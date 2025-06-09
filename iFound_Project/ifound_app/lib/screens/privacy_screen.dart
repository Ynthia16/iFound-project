import 'package:flutter/material.dart';
import '../components/ifound_appbar.dart';
import '../components/ifound_background.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IFoundBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const IFoundAppBar(title: 'Privacy & Safeguarding'),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.lock_rounded, color: Color(0xFF2196F3)),
                title: const Text('Your privacy matters'),
                subtitle: const Text('We never share your personal info or document images.'),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.verified_user_rounded, color: Color(0xFF2196F3)),
                title: const Text('Safe & Secure'),
                subtitle: const Text('All reports are reviewed and only relevant info is used for matching.'),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.shield_rounded, color: Color(0xFF2196F3)),
                title: const Text('No direct contact'),
                subtitle: const Text('You never have to meet strangers. All claims go through trusted institutions.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 