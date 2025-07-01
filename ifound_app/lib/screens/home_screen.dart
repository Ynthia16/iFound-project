import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/post_feed_item.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../utils/responsive_helper.dart';

/// Home screen with real-time match checking and notifications.
class HomeScreen extends StatefulWidget {
  final void Function(int) onTabSelected;
  final void Function(int)? onNotificationCountChanged;
  final void Function(List<Map<String, dynamic>>)? onMatchesUpdated;
  
  const HomeScreen({
    super.key, 
    required this.onTabSelected,
    this.onNotificationCountChanged,
    this.onMatchesUpdated,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final List<Map<String, dynamic>> _userMatches = [];
  bool _hasMatches = false;
  bool _isLoading = true;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _loadReports();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final allReports = await _firestoreService.getReportsOnce();

        // Only get matches for documents the user has declared as LOST
        final userLostReports = allReports
            .where((report) => report['userId'] == user.uid && report['status'] == 'lost')
            .toList();

        // Check for matches for each lost report
        List<Map<String, dynamic>> allMatches = [];
        for (final report in userLostReports) {
          final matches = await _firestoreService.checkForMatches(
            name: report['name'],
            docType: report['docType'],
            status: report['status'],
            userId: user.uid,
          );
          allMatches.addAll(matches);
        }

        if (mounted) {
          setState(() {
            _userMatches.clear(); // Clear first to avoid duplication
            _userMatches.addAll(allMatches);
            _hasMatches = allMatches.isNotEmpty;
            _isLoading = false;
          });

          // Update notification count and pass matches data
          widget.onNotificationCountChanged?.call(allMatches.length);
          widget.onMatchesUpdated?.call(allMatches);

          // Start animations
          _fadeController.forward();
          _slideController.forward();
        }
      } else {
        final allReports = await _firestoreService.getReportsOnce();
        if (mounted) {
          setState(() {
            _userMatches.addAll(allReports);
            _hasMatches = true;
            _isLoading = false;
          });

          // Update notification count and pass matches data
          widget.onNotificationCountChanged?.call(allReports.length);
          widget.onMatchesUpdated?.call(allReports);

          // Start animations
          _fadeController.forward();
          _slideController.forward();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showNotifications(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    
    // Responsive sizing
    final modalHeight = isSmallScreen ? 0.8 : 0.7;
    final headerPadding = isSmallScreen ? 16.0 : 20.0;
    final contentPadding = isSmallScreen ? 12.0 : 16.0;
    final iconSize = isSmallScreen ? 18.0 : 20.0;
    final titleFontSize = isSmallScreen ? 18.0 : 20.0;
    final itemMargin = isSmallScreen ? 8.0 : 12.0;
    final itemIconSize = isSmallScreen ? 18.0 : 20.0;
    final itemTitleFontSize = isSmallScreen ? 14.0 : 16.0;
    final itemSubtitleFontSize = isSmallScreen ? 11.0 : 12.0;
    final emptyIconSize = isSmallScreen ? 48.0 : 64.0;
    final emptyTitleFontSize = isSmallScreen ? 16.0 : 18.0;
    final emptySubtitleFontSize = isSmallScreen ? 12.0 : 14.0;
    final itemPadding = isSmallScreen ? 12.0 : 16.0;
    final itemVerticalPadding = isSmallScreen ? 6.0 : 8.0;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * modalHeight,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(headerPadding),
              decoration: BoxDecoration(
                color: isDark 
                  ? const Color(0xFF2196F3).withOpacity(0.15)
                  : const Color(0xFFE8F5E8),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                    decoration: BoxDecoration(
                      color: isDark 
                        ? const Color(0xFF2196F3).withOpacity(0.2)
                        : Colors.green[100],
                      borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded, 
                      color: isDark ? const Color(0xFF2196F3) : Colors.green[700],
                      size: iconSize,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: Text(
                      'Match Notifications'.tr(),
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF2196F3) : Colors.green[700],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      size: isSmallScreen ? 20 : 24,
                    ),
                    padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
                    constraints: BoxConstraints(
                      minWidth: isSmallScreen ? 40 : 48,
                      minHeight: isSmallScreen ? 40 : 48,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _userMatches.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: emptyIconSize,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          Text(
                            'No matches found yet'.tr(),
                            style: TextStyle(
                              fontSize: emptyTitleFontSize,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 8),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 0),
                            child: Text(
                              'You\'ll see notifications here when matches are found.'.tr(),
                              style: TextStyle(
                                fontSize: emptySubtitleFontSize,
                                color: isDark ? Colors.white54 : Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(contentPadding),
                      itemCount: _userMatches.length,
                      itemBuilder: (context, index) {
                        final match = _userMatches[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: itemMargin),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF404040) : Colors.grey[200]!,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark 
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                              decoration: BoxDecoration(
                                color: isDark 
                                  ? const Color(0xFF2196F3).withOpacity(0.1)
                                  : Colors.green[100],
                                borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                              ),
                              child: Icon(
                                Icons.description_rounded,
                                color: isDark ? const Color(0xFF2196F3) : Colors.green[700],
                                size: itemIconSize,
                              ),
                            ),
                            title: Text(
                              match['name'] ?? 'Unknown Document',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: itemTitleFontSize,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${match['docType'] ?? 'Document'} - ${match['sector'] ?? 'Unknown Sector'}',
                                  style: TextStyle(
                                    fontSize: itemSubtitleFontSize,
                                    color: isDark ? Colors.white70 : Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 1 : 2),
                                Text(
                                  'Status: ${match['status'] ?? 'Unknown'}',
                                  style: TextStyle(
                                    color: (match['status'] == 'found') 
                                        ? Colors.green 
                                        : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                    fontSize: itemSubtitleFontSize,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: isSmallScreen ? 14 : 16,
                              color: isDark ? Colors.white54 : Colors.grey[400],
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navigate to match details
                            },
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: itemPadding, 
                              vertical: itemVerticalPadding
                            ),
                          ),
                        );
                      },
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
                            _hasMatches = false;
                          });
                          // Update main shell when clearing matches
                          widget.onMatchesUpdated?.call([]);
                          widget.onNotificationCountChanged?.call(0);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark 
                            ? Colors.red.withOpacity(0.1)
                            : Colors.red[50],
                          foregroundColor: Colors.red[700],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                        ),
                        child: Text(
                          'Clear All'.tr(),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return _isLoading
        ? _buildLoadingState()
        : FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                decoration: BoxDecoration(
                  gradient: isDark 
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF1E1E1E),
                          const Color(0xFF2A2A2A),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          const Color(0xFFF8F9FA),
                        ],
                      ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Match notification (only show if there are matches)
                      if (_hasMatches && _userMatches.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: _buildMobileMatchNotification(isDark),
                        ),
                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildMobileActionButtons(isDark),
                      ),
                      // Recent activity header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildMobileRecentActivityHeader(isDark),
                      ),
                      const SizedBox(height: 8),
                      // Reports list
                      Expanded(
                        child: _buildEnhancedReportsList(isDark),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your dashboard...'.tr(),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMatchNotification(bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final padding = isSmallScreen ? 16.0 : 20.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final titleSize = isSmallScreen ? 16.0 : 18.0;
    final subtitleSize = isSmallScreen ? 12.0 : 14.0;
    final buttonSize = isSmallScreen ? 12.0 : 14.0;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber[50]!,
            Colors.orange[50]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showNotifications(context),
          child: Container(
            padding: EdgeInsets.all(padding),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.celebration_rounded,
                    color: Colors.amber[700],
                    size: iconSize,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_userMatches.length} match${_userMatches.length > 1 ? 'es' : ''} found!',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: titleSize,
                          color: Colors.amber[800],
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        'Tap to view your matches',
                        style: GoogleFonts.poppins(
                          fontSize: subtitleSize,
                          color: Colors.amber[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16, 
                    vertical: isSmallScreen ? 6 : 8
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber[400]!, Colors.amber[600]!],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'View',
                    style: GoogleFonts.poppins(
                      fontSize: buttonSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileActionButtons(bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final buttonSpacing = isSmallScreen ? 12.0 : 16.0;
    
    return Row(
      children: [
        Expanded(
          child: _buildMobileActionButton(
            label: 'Report Lost'.tr(),
            icon: Icons.search_rounded,
            color: Colors.red,
            isDark: isDark,
            onTap: () => widget.onTabSelected(1),
            isSmallScreen: isSmallScreen,
          ),
        ),
        SizedBox(width: buttonSpacing),
        Expanded(
          child: _buildMobileActionButton(
            label: 'Report Found'.tr(),
            icon: Icons.check_circle_rounded,
            color: Colors.green,
            isDark: isDark,
            onTap: () => widget.onTabSelected(2),
            isSmallScreen: isSmallScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return Container(
      height: isSmallScreen ? 56 : 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 20, 
              vertical: isSmallScreen ? 12 : 16
            ),
            child: isSmallScreen 
              ? Center(
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        label,
                        style: GoogleFonts.poppins(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileRecentActivityHeader(bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final padding = isSmallScreen ? 16.0 : 20.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final fontSize = isSmallScreen ? 16.0 : 18.0;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: isDark 
          ? const Color(0xFF2A2A2A)
          : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark 
            ? const Color(0xFF404040)
            : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.history_rounded,
              color: const Color(0xFF2196F3),
              size: iconSize,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Text(
              'Recent Activity'.tr(),
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark 
                ? const Color(0xFF404040)
                : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: _loadReports,
              icon: Icon(
                Icons.refresh_rounded,
                color: const Color(0xFF2196F3),
                size: iconSize,
              ),
              tooltip: 'Refresh',
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
              constraints: BoxConstraints(
                minWidth: isSmallScreen ? 40 : 48,
                minHeight: isSmallScreen ? 40 : 48,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedReportsList(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark 
                      ? const Color(0xFF2A2A2A)
                      : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading recent activity...'.tr(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark 
                  ? const Color(0xFF2A2A2A)
                  : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load reports',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check your connection and try again',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });
                      _loadReports();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark 
                  ? const Color(0xFF2A2A2A)
                  : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: const Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No reports yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to report a lost or found document!',
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white60 : Colors.grey[600],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => widget.onTabSelected(1),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Report Lost Document'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['timestamp'] as Timestamp?;
            final timeAgo =
                timestamp != null ? _getTimeAgo(timestamp.toDate()) : '';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: PostFeedItem(
                name: data['name'] ?? '',
                docType: data['docType'] ?? '',
                status: data['status'] ?? '',
                sector: data['sector'] ?? '',
                timeAgo: timeAgo,
              ),
            );
          },
        );
      },
    );
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }


}
