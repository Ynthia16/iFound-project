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
    return SafeArea(
      child: Drawer(
        backgroundColor: isDark ? const Color(0xFF181A20) : Colors.white,
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
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          userName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome to iFound'.tr(),
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
            const Divider(height: 36),
            _buildDrawerItem(
              context: context,
              icon: Icons.logout_rounded,
              title: 'logout'.tr(),
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: isDark ? const Color(0xFF23242B) : Colors.white,
                    title: Text(
                      'Logout'.tr(),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w700,
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
                if (shouldLogout == true) {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                }
              },
              isDark: isDark,
              isDestructive: true,
            ),
          ],
        ),
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
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark 
          ? const Color(0xFF23242B).withOpacity(0.7)
          : Colors.grey[50],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive 
            ? Colors.red 
            : (isDark ? Colors.white : const Color(0xFF2196F3)),
          size: 26,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: isDestructive 
              ? Colors.red 
              : (isDark ? Colors.white : Colors.black87),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      ),
    );
  }
} 