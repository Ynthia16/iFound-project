import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_helper.dart';

class IFoundOnboardingPage extends StatelessWidget {
  final String asset;
  final String title;
  final String subtitle;
  const IFoundOnboardingPage({
    super.key,
    required this.asset,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive sizing
    final imageSize = isSmallScreen ? 120.0 : 180.0;
    final titleFontSize = isSmallScreen ? 20.0 : 24.0;
    final subtitleFontSize = isSmallScreen ? 14.0 : 16.0;
    final horizontalPadding = isSmallScreen ? 16.0 : 32.0;
    final verticalSpacing = isSmallScreen ? 16.0 : 32.0;
    final smallSpacing = isSmallScreen ? 8.0 : 16.0;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: screenHeight * 0.6,
          maxHeight: screenHeight * 0.8,
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: SvgPicture.asset(
                    asset,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: verticalSpacing),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2196F3),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: smallSpacing),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: subtitleFontSize,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 