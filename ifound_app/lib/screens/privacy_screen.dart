import 'package:flutter/material.dart';
import '../components/ifound_appbar.dart';
import '../components/ifound_background.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_helper.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    // Responsive sizing
    final padding = isSmallScreen ? 16.0 : 24.0;
    final cardPadding = isSmallScreen ? 16.0 : 20.0;
    final iconSize = isSmallScreen ? 24.0 : 28.0;
    final iconPadding = isSmallScreen ? 10.0 : 12.0;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final subtitleFontSize = isSmallScreen ? 13.0 : 14.0;
    final spacing = isSmallScreen ? 16.0 : 20.0;

    return IFoundBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const IFoundAppBar(
          title: 'Privacy & Safeguarding',
          showLogo: true,
        ),
        body: ListView(
          padding: EdgeInsets.all(padding),
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20)),
              elevation: 6,
              child: Container(
                padding: EdgeInsets.all(cardPadding),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(iconPadding),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        color: const Color(0xFF2196F3),
                        size: iconSize,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your privacy matters',
                            style: GoogleFonts.poppins(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 2 : 4),
                          Text(
                            'We never share your personal info or document images.',
                            style: GoogleFonts.poppins(
                              fontSize: subtitleFontSize,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20)),
              elevation: 6,
              child: Container(
                padding: EdgeInsets.all(cardPadding),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(iconPadding),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                      ),
                      child: Icon(
                        Icons.verified_user_rounded,
                        color: const Color(0xFF2196F3),
                        size: iconSize,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Safe & Secure',
                            style: GoogleFonts.poppins(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 2 : 4),
                          Text(
                            'All reports are reviewed and only relevant info is used for matching.',
                            style: GoogleFonts.poppins(
                              fontSize: subtitleFontSize,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20)),
              elevation: 6,
              child: Container(
                padding: EdgeInsets.all(cardPadding),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(iconPadding),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                      ),
                      child: Icon(
                        Icons.shield_rounded,
                        color: const Color(0xFF2196F3),
                        size: iconSize,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No direct contact',
                            style: GoogleFonts.poppins(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 2 : 4),
                          Text(
                            'You never have to meet strangers. All claims go through trusted institutions.',
                            style: GoogleFonts.poppins(
                              fontSize: subtitleFontSize,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}