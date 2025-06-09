import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

class IFoundDrawer extends StatelessWidget {
  final String userName;
  final String? avatarAsset;
  final VoidCallback? onFeedback;
  final VoidCallback? onPrivacy;
  final VoidCallback? onSettings;
  final VoidCallback? onLogout;
  const IFoundDrawer({
    super.key,
    required this.userName,
    this.avatarAsset,
    this.onFeedback,
    this.onPrivacy,
    this.onSettings,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (avatarAsset != null)
                  SvgPicture.asset(avatarAsset!, width: 48, height: 48),
                if (avatarAsset != null) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    userName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.feedback_rounded, color: Color(0xFF2196F3)),
            title: Text('feedback'.tr()),
            onTap: onFeedback,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_rounded, color: Color(0xFF2196F3)),
            title: Text('privacy_policy'.tr()),
            onTap: onPrivacy,
          ),
          ListTile(
            leading: const Icon(Icons.settings_rounded, color: Color(0xFF2196F3)),
            title: Text('settings'.tr()),
            onTap: onSettings,
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: Text('logout'.tr()),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (shouldLogout == true) {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }
} 