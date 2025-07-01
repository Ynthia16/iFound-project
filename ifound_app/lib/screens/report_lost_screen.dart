import 'package:flutter/material.dart';
import '../components/report_document_form.dart';
import '../components/ifound_background.dart';
import '../components/post_feed_item.dart';
import '../services/firestore_service.dart';
import '../utils/responsive_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Screen for reporting and viewing lost documents
class ReportLostScreen extends StatefulWidget {
  const ReportLostScreen({super.key});
  @override
  State<ReportLostScreen> createState() => _ReportLostScreenState();
}

class _ReportLostScreenState extends State<ReportLostScreen> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _myReports = [];
  List<Map<String, dynamic>> _allReports = [];
  bool _isLoading = true;
  bool _hasError = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final allReports = await _firestoreService.getReportsOnce(status: 'lost');
        final myReports = allReports.where((report) => report['userId'] == user.uid).toList();
        
        if (mounted) {
          setState(() {
            _myReports = myReports;
            _allReports = allReports;
            _isLoading = false;
          });
        }
      } else {
        final allReports = await _firestoreService.getReportsOnce(status: 'lost');
        if (mounted) {
      setState(() {
            _allReports = allReports;
        _isLoading = false;
      });
        }
      }
    } catch (e) {
      if (mounted) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      }
    }
  }

  void _showAddLostDocumentForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ReportDocumentForm(
          title: 'Report Lost Document',
          buttonText: 'Submit Lost Report',
          status: 'lost',
          onSubmit: (name, docType, institution, sector) async {
            final user = FirebaseAuth.instance.currentUser;
            
            if (user != null) {
              try {
                await _firestoreService.addReport(
                  name: name,
                  docType: docType,
                  institution: institution,
                  sector: sector,
                  status: 'lost',
                  userId: user.uid,
                );
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Lost document report submitted successfully!'.tr()),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  _loadReports();
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Failed to submit report. Please try again.'.tr()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } else {
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ You must be logged in to submit a report.'.tr()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final hasUser = user != null;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    
    // Responsive sizing
    final tabFontSize = isSmallScreen ? 12.0 : 14.0;
    final tabIconSize = isSmallScreen ? 16.0 : 18.0;
    final badgeFontSize = isSmallScreen ? 10.0 : 11.0;
    
    return IFoundBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            hasUser ? (isSmallScreen ? 100 : 110) : (isSmallScreen ? 70 : 80)
          ),
          child: Container(
            color: Colors.transparent,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: isSmallScreen ? 12 : 16,
                      left: isSmallScreen ? 12 : 20,
                      right: isSmallScreen ? 12 : 20,
                      bottom: isSmallScreen ? 4 : 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Lost Documents'.tr(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 20 : 24,
                              color: Colors.red[700],
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.red.withOpacity(0.08),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh, size: isSmallScreen ? 18 : 22, color: Colors.red[700]),
                          onPressed: _loadReports,
                          tooltip: 'Refresh'.tr(),
                          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                          constraints: BoxConstraints(
                            minWidth: isSmallScreen ? 36 : 44,
                            minHeight: isSmallScreen ? 36 : 44,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 3,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 6),
                  if (hasUser)
                    Flexible(
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.red,
                        labelColor: Colors.red,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: GoogleFonts.poppins(fontSize: tabFontSize, fontWeight: FontWeight.w600),
                        unselectedLabelStyle: GoogleFonts.poppins(fontSize: tabFontSize, fontWeight: FontWeight.w500),
                        indicatorSize: TabBarIndicatorSize.tab,
                        isScrollable: isSmallScreen,
                        tabs: [
                          Tab(
                            child: isSmallScreen 
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person, size: tabIconSize * 0.8),
                                    if (_myReports.isNotEmpty) ...[
                                      SizedBox(height: 1),
                                      Container(
                                        padding: EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${_myReports.length}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white, 
                                            fontSize: 7,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person, size: tabIconSize),
                                    SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'My Reports'.tr(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (_myReports.isNotEmpty) ...[
                                      SizedBox(width: 6),
                                      Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${_myReports.length}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white, 
                                            fontSize: badgeFontSize,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                          ),
                          Tab(
                            child: isSmallScreen 
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.public, size: tabIconSize * 0.8),
                                    if (_allReports.isNotEmpty) ...[
                                      SizedBox(height: 1),
                                      Container(
                                        padding: EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${_allReports.length}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white, 
                                            fontSize: 7,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.public, size: tabIconSize),
                                    SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'All Reports'.tr(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (_allReports.isNotEmpty) ...[
                                      SizedBox(width: 6),
                                      Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${_allReports.length}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white, 
                                            fontSize: badgeFontSize,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // My Reports Tab
            _buildReportsList(_myReports, hasUser, isSmallScreen),
            // All Reports Tab
            _buildReportsList(_allReports, hasUser, isSmallScreen),
          ],
        ),
        floatingActionButton: hasUser ? FloatingActionButton.extended(
          onPressed: _showAddLostDocumentForm,
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          icon: Icon(Icons.add, size: isSmallScreen ? 20 : 24),
          label: Text(
            'Report Lost'.tr(),
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ) : null,
      ),
    );
  }

  Widget _buildReportsList(List<Map<String, dynamic>> reports, bool hasUser, bool isSmallScreen) {
    final padding = isSmallScreen ? 12.0 : 20.0;
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading reports...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Failed to load reports'.tr()),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadReports,
              child: Text('Retry'.tr()),
            ),
          ],
        ),
      );
    }

    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No lost reports yet'.tr(), style: GoogleFonts.poppins(fontSize: 18)),
            SizedBox(height: 8),
            Text('Be the first to report a lost document!'.tr(), 
                 style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView.separated(
        padding: EdgeInsets.all(padding),
        itemCount: reports.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final data = reports[index];
          final hasMatch = data['hasMatch'] == true;
          
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Stack(
              children: [
                PostFeedItem(
                  name: data['name'] ?? '',
                  docType: data['docType'] ?? '',
                  status: data['status'] ?? '',
                  sector: data['sector'] ?? '',
                  timeAgo: _getTimeAgo(data['timestamp']),
                ),
                if (hasMatch)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('MATCHED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  String _getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return '';
    
    try {
      final dateTime = timestamp is Timestamp ? timestamp.toDate() : DateTime.parse(timestamp.toString());
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
    } catch (e) {
      return '';
    }
  }
}