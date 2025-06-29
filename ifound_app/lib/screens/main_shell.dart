import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../components/ifound_drawer.dart';
import '../components/ifound_navbar.dart';
import '../components/ifound_logo.dart';
import 'home_screen.dart';
import 'report_lost_screen.dart';
import 'report_found_screen.dart';
import 'feedback_screen.dart';
import 'settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// Main navigation shell with bottom navigation bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  int _notificationCount = 0;
  List<Map<String, dynamic>> _userMatches = [];
  
  // Cache the screens to prevent recreation
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  void _initializeScreens() {
    _screens = [
      HomeScreen(
        onTabSelected: goToTab,
        onNotificationCountChanged: updateNotificationCount,
        onMatchesUpdated: updateMatches,
      ),
      const ReportLostScreen(),
      const ReportFoundScreen(),
      const FeedbackScreen(),
    ];
  }

  void goToTab(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void updateNotificationCount(int count) {
    if (mounted && _notificationCount != count) {
      setState(() {
        _notificationCount = count;
      });
    }
  }

  void updateMatches(List<Map<String, dynamic>> matches) {
    if (mounted) {
      setState(() {
        _userMatches = List.from(matches);
      });
    }
  }

  String _getDisplayName(User? user) {
    if (user == null) return 'Guest';
    return user.displayName ?? user.email?.split('@').first ?? 'User';
  }

  void _showNotifications(BuildContext context) {
    // Show a more detailed notification modal with actual match data
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.notifications_active, 
                      color: Color(0xFF2196F3),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      'Match Notifications'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 26),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(
                        minWidth: 52,
                        minHeight: 52,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _userMatches.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _userMatches.length,
                      itemBuilder: (context, index) {
                        final match = _userMatches[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(20),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.description, 
                                color: Color(0xFF2196F3),
                                size: 26,
                              ),
                            ),
                            title: Text(
                              match['name'] ?? 'Unknown Document',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text(
                                  '${match['docType'] ?? 'Document'} - ${match['sector'] ?? 'Unknown Sector'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Status: ${match['status'] ?? 'Unknown'}',
                                  style: GoogleFonts.poppins(
                                    color: (match['status'] == 'found') 
                                        ? Colors.green 
                                        : Colors.orange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.arrow_forward_ios, size: 20),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navigate to match details
                            },
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              Icons.notifications_none,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'No matches found yet'.tr(),
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'You\'ll see notifications here when matches are found.'.tr(),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
            if (_userMatches.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _userMatches.clear();
                            _notificationCount = 0;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red[700],
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Clear All'.tr(),
                          style: GoogleFonts.poppins(
                            fontSize: 16, 
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = _getDisplayName(user);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _currentIndex == 0 ? AppBar(
        automaticallyImplyLeading: true,
        title: Row(
          children: [
            IFoundLogo(size: 36),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome back,',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  Text(
                    displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: isDark ? 0 : 1,
        shadowColor: isDark ? Colors.transparent : Colors.black12,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          size: 26,
        ),
        actions: [
          // Notifications
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isDark 
                    ? const Color(0xFF2A2A2A) 
                    : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(18),
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
                    size: 26,
                  ),
                  onPressed: () => _showNotifications(context),
                  tooltip: 'Notifications',
                  padding: const EdgeInsets.all(14),
                  constraints: const BoxConstraints(
                    minWidth: 52,
                    minHeight: 52,
                  ),
                ),
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 18,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _notificationCount.toString(),
                      style: GoogleFonts.poppins(
                        color: Colors.white, 
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Theme toggle
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isDark 
                ? const Color(0xFF2A2A2A) 
                : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(18),
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
                size: 26,
              ),
              onPressed: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
              tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              padding: const EdgeInsets.all(14),
              constraints: const BoxConstraints(
                minWidth: 52,
                minHeight: 52,
              ),
            ),
          ),
        ],
      ) : null,
      drawer: _currentIndex == 0 ? IFoundDrawer(
        userName: displayName,
        avatarAsset: null,
        onFeedback: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FeedbackScreen()));
        },
        onSettings: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()));
        },
      ) : null,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: IFoundNavBar(
        currentIndex: _currentIndex,
        onTap: goToTab,
      ),
    );
  }
}