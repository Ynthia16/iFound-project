import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'package:easy_localization/easy_localization.dart';

class IFoundAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showNotifications;
  final int? notificationCount;
  final VoidCallback? onNotifications;
  const IFoundAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showNotifications = false,
    this.notificationCount,
    this.onNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Image.asset('assets/ifound_logo.png', height: 32, width: 32, errorBuilder: (_, __, ___) => const SizedBox()),
          const SizedBox(width: 8),
          Text(
            title.tr(),
            style: GoogleFonts.poppins(
              color: const Color(0xFF2196F3),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF2196F3)),
      actions: [
        if (showNotifications && notificationCount != null && notificationCount! > 0)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_rounded, color: Color(0xFF2196F3)),
                onPressed: onNotifications,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    notificationCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        IconButton(
          icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.wb_sunny_rounded : Icons.nightlight_round, color: const Color(0xFF2196F3)),
          onPressed: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
        ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 