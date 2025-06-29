import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/theme_provider.dart';
import 'ifound_logo.dart';

class IFoundAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showNotifications;
  final int? notificationCount;
  final VoidCallback? onNotifications;
  final bool showLogo;
  final bool showBackButton;
  
  const IFoundAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showNotifications = false,
    this.notificationCount,
    this.onNotifications,
    this.showLogo = true,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return AppBar(
      automaticallyImplyLeading: true,
      title: showLogo 
        ? IFoundLogo(size: 32)
        : Text(
            title.tr(),
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: isDark ? 0 : 1,
      shadowColor: isDark ? Colors.transparent : Colors.black12,
      iconTheme: IconThemeData(
        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
      ),
      actions: [
        if (showNotifications)
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isDark 
                    ? const Color(0xFF2A2A2A) 
                    : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark 
                      ? const Color(0xFF404040)
                      : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_rounded, 
                    color: isDark ? Colors.white70 : const Color(0xFF2196F3),
                    size: 20,
                  ),
                onPressed: onNotifications,
                  tooltip: 'Notifications',
                ),
              ),
              if (notificationCount != null && notificationCount! > 0)
              Positioned(
                  right: 16,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                    color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                  ),
                  child: Text(
                    notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                  ),
                ),
              ),
            ],
          ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: isDark 
              ? const Color(0xFF2A2A2A) 
              : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark 
                ? const Color(0xFF404040)
                : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round, 
              color: isDark ? Colors.amber : const Color(0xFF2196F3),
              size: 20,
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}