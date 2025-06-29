import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

class IFoundDrawer extends StatelessWidget {
  final String userName;
  final String? avatarAsset;
  final VoidCallback? onFeedback;
  final VoidCallback? onSettings;
  final VoidCallback? onLogout;
  const IFoundDrawer({
    super.key,
    required this.userName,
    this.avatarAsset,
    this.onFeedback,
    this.onSettings,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                  ? [const Color(0xFF2196F3), const Color(0xFF1976D2)]
                  : [const Color(0xFF2196F3), const Color(0xFF64B5F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    userName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                    ),
                const SizedBox(height: 8),
                Text(
                  'Welcome to iFound'.tr(),
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildDrawerItem(
            context: context,
            icon: Icons.people_rounded,
            title: 'Community Wall'.tr(),
            onTap: onFeedback,
            isDark: isDark,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.settings_rounded,
            title: 'settings'.tr(),
            onTap: onSettings,
            isDark: isDark,
          ),
          const Divider(height: 32),
          _buildDrawerItem(
            context: context,
            icon: Icons.logout_rounded,
            title: 'logout'.tr(),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  title: Text(
                    'Logout'.tr(),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to log out?'.tr(),
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel'.tr(),
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Logout'.tr()),
                    ),
                  ],
                ),
              );
              if (shouldLogout == true && context.mounted) {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            isDark: isDark,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark 
          ? const Color(0xFF2A2A2A).withOpacity(0.5)
          : Colors.grey[50],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive 
            ? Colors.red 
            : (isDark ? Colors.white70 : const Color(0xFF2196F3)),
          size: 22,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: isDestructive 
              ? Colors.red 
              : (isDark ? Colors.white : Colors.black87),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
} 