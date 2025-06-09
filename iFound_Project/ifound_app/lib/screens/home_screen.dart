import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/ifound_button.dart';
import '../components/post_feed_item.dart';
import '../components/ifound_action_button.dart';
import '../components/ifound_appbar.dart';
import '../components/ifound_background.dart';
import '../components/ifound_welcome_header.dart';
import '../components/ifound_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'feedback_wall_screen.dart';
import 'privacy_screen.dart';
import 'settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';

/// Home screen .
class HomeScreen extends StatelessWidget {
  final void Function(int) onTabSelected;
  const HomeScreen({super.key, required this.onTabSelected});

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.notifications_active_rounded, color: Colors.amber[800]),
              title: const Text('Match found!'),
              subtitle: const Text('A document matching your report was found at Kacyiru Police Station.'),
              trailing: TextButton(
                onPressed: () {}, // TODO: Viewing match details
                child: const Text('View'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? user?.email?.split('@').first ?? 'User';
    final shortName = displayName.trim().split(' ').take(2).join(' ');
    // Mock feed data
    final posts = [
      PostFeedItem(
        name: 'Jane Doe',
        docType: 'National ID',
        status: 'found',
        sector: 'Kacyiru Police Station',
        timeAgo: '2h ago',
      ),
      PostFeedItem(
        name: 'John Smith',
        docType: 'School Card',
        status: 'lost',
        sector: 'Remera Sector Office',
        timeAgo: '3h ago',
      ),
      PostFeedItem(
        name: 'Alice',
        docType: 'Certificate',
        status: 'found',
        sector: 'Nyarugenge Police Station',
        timeAgo: '5h ago',
      ),
    ];
    // Mock: show a match notification
    final hasMatch = true;
    final notificationCount = hasMatch ? 1 : 0;
    return IFoundBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: IFoundAppBar(
          title: 'app_name'.tr(),
          showNotifications: true,
          notificationCount: notificationCount,
          onNotifications: () => _showNotifications(context),
        ),
        drawer: IFoundDrawer(
          userName: shortName,
          avatarAsset: 'assets/ifound_logo.svg',
          onFeedback: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackWallScreen()));
          },
          onPrivacy: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyScreen()));
          },
          onSettings: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: IFoundWelcomeHeader(
                name: shortName,
                illustrationAsset: 'assets/ifound_logo.svg',
              ),
            ),
            if (hasMatch)
              Card(
                color: Colors.amber[100],
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Icon(Icons.notifications_active_rounded, color: Colors.amber[800]),
                  title: Text('Match found!', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  subtitle: Text('A document matching your report was found at Kacyiru Police Station.'),
                  trailing: TextButton(
                    onPressed: () {}, // TODO: Viewing match details
                    child: const Text('View'),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: IFoundActionButton(
                      label: 'iLost',
                      icon: Icons.search_rounded,
                      color: Colors.red,
                      onTap: () => onTabSelected(1),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: IFoundActionButton(
                      label: 'iFound',
                      icon: Icons.check_circle_rounded,
                      color: Colors.green,
                      onTap: () => onTabSelected(2),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Text(
                'Recent Activity',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2196F3)),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: ListView.separated(
                  key: ValueKey(posts.length),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: posts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => posts[index],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}