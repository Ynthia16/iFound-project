import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../components/ifound_drawer.dart';
import '../components/ifound_navbar.dart';
import 'home_screen.dart';
import 'report_lost_screen.dart';
import 'report_found_screen.dart';
import 'feedback_screen.dart';
import 'settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/responsive_helper.dart';

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
  bool _isLoading = true;

  // Cache the screens to prevent recreation
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _initializeScreens();
    _loadUserData();
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

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Pre-load user data to ensure smooth navigation
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Error loading user data: $e
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    
    // Responsive sizing
    final modalHeight = isSmallScreen ? 0.9 : 0.85;
    final headerPadding = isSmallScreen ? 16.0 : 24.0;
    final contentPadding = isSmallScreen ? 12.0 : 20.0;
    final iconSize = isSmallScreen ? 20.0 : 26.0;
    final titleFontSize = isSmallScreen ? 20.0 : 24.0;
    final closeIconSize = isSmallScreen ? 20.0 : 26.0;
    final closeButtonSize = isSmallScreen ? 44.0 : 52.0;
    final itemPadding = isSmallScreen ? 12.0 : 20.0;
    final itemMargin = isSmallScreen ? 8.0 : 16.0;
    final itemIconSize = isSmallScreen ? 20.0 : 26.0;
    final itemTitleFontSize = isSmallScreen ? 16.0 : 18.0;
    final itemSubtitleFontSize = isSmallScreen ? 13.0 : 15.0;
    final emptyIconSize = isSmallScreen ? 60.0 : 80.0;
    final emptyTitleFontSize = isSmallScreen ? 18.0 : 22.0;
    final emptySubtitleFontSize = isSmallScreen ? 14.0 : 16.0;
    final buttonPadding = isSmallScreen ? 14.0 : 18.0;
    final buttonFontSize = isSmallScreen ? 14.0 : 16.0;

    // Show a more detailed notification modal with actual match data
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * modalHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(headerPadding),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 10 : 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 18),
                    ),
                    child: Icon(
                      Icons.notifications_active,
                      color: const Color(0xFF2196F3),
                      size: iconSize,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 18),
                  Expanded(
                    child: Text(
                      'Match Notifications'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, size: closeIconSize),
                      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                      constraints: BoxConstraints(
                        minWidth: closeButtonSize,
                        minHeight: closeButtonSize,
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
                      padding: EdgeInsets.all(contentPadding),
                      itemCount: _userMatches.length,
                      itemBuilder: (context, index) {
                        final match = _userMatches[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: itemMargin),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(itemPadding),
                            leading: Container(
                              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                              ),
                              child: Icon(
                                Icons.description,
                                color: const Color(0xFF2196F3),
                                size: itemIconSize,
                              ),
                            ),
                            title: Text(
                              match['name'] ?? 'Unknown Document',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: itemTitleFontSize,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: isSmallScreen ? 4 : 6),
                                Text(
                                  '${match['docType'] ?? 'Document'} - ${match['sector'] ?? 'Unknown Sector'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: itemSubtitleFontSize,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 2 : 4),
                                Text(
                                  'Status: ${match['status'] ?? 'Unknown'}',
                                  style: GoogleFonts.poppins(
                                    color: (match['status'] == 'found')
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: itemSubtitleFontSize,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios, 
                                size: isSmallScreen ? 16 : 20
                              ),
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
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 24),
                            ),
                            child: Icon(
                              Icons.notifications_none,
                              size: emptyIconSize,
                              color: Colors.grey[400],
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 28),
                          Text(
                            'No matches found yet'.tr(),
                            style: GoogleFonts.poppins(
                              fontSize: emptyTitleFontSize,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 0),
                            child: Text(
                              'You\'ll see notifications here when matches are found.'.tr(),
                              style: GoogleFonts.poppins(
                                fontSize: emptySubtitleFontSize,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (_userMatches.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(contentPadding),
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
                          padding: EdgeInsets.symmetric(vertical: buttonPadding),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 18),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Clear All'.tr(),
                          style: GoogleFonts.poppins(
                            fontSize: buttonFontSize,
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

    // Show loading screen while initializing
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Loading your dashboard...'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Color(0xFF2196F3),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'iFound',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    'Welcome, ${displayName.split(' ').first}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF181A20) : Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          size: 24,
        ),
        actions: [
          // Notification bell with badge
          Stack(
            children: [
              IconButton(
                onPressed: () => _showNotifications(context),
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _notificationCount > 9 ? '9+' : _notificationCount.toString(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: IFoundDrawer(
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
      ),
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