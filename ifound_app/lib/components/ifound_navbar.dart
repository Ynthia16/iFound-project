import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class IFoundNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const IFoundNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Widget _buildFoundIcon(BuildContext context, bool isSelected, bool isDark, double iconSize) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.document_scanner_outlined,
          size: iconSize,
          color: isSelected 
            ? const Color(0xFF2196F3)
            : isDark ? Colors.grey[300] : Colors.grey[700],
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.green[600],
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.white,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.check,
              size: iconSize * 0.4,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isVerySmallScreen = screenWidth < 350;
    final navbarHeight = isSmallScreen ? 75.0 : 85.0;
    final innerHeight = isSmallScreen ? 65.0 : 75.0;
    final horizontalPadding = isSmallScreen ? screenWidth * 0.015 : screenWidth * 0.02;
    
    return Container(
      height: navbarHeight,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A20) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.4)
              : Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF23242B) : Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: innerHeight,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isSmallScreen ? 6 : 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home_rounded, 'Home'.tr(), isDark, isSmallScreen, isVerySmallScreen),
              _buildNavItem(context, 1, Icons.find_in_page_outlined, isVerySmallScreen ? 'Lost'.tr() : 'Report Lost'.tr(), isDark, isSmallScreen, isVerySmallScreen),
              _buildFoundNavItem(context, 2, isVerySmallScreen ? 'Found'.tr() : 'Report Found'.tr(), isDark, isSmallScreen, isVerySmallScreen),
              _buildNavItem(context, 3, Icons.star_rounded, isVerySmallScreen ? 'Rate'.tr() : 'Feedback'.tr(), isDark, isSmallScreen, isVerySmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoundNavItem(BuildContext context, int index, String label, bool isDark, bool isSmallScreen, bool isVerySmallScreen) {
    final isSelected = currentIndex == index;
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = isVerySmallScreen ? 20.0 : (isSmallScreen ? 18.0 : 20.0);
    final fontSize = isVerySmallScreen ? 8.0 : (isSmallScreen ? 9.0 : 10.0);
    final horizontalPadding = isVerySmallScreen ? screenWidth * 0.01 : (isSmallScreen ? screenWidth * 0.008 : screenWidth * 0.012);
    
    return Expanded(
      child: GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isVerySmallScreen ? 6 : (isSmallScreen ? 4 : 6),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected 
              ? const Color(0xFF2196F3).withOpacity(0.2)
              : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFoundIcon(context, isSelected, isDark, iconSize),
              SizedBox(height: isVerySmallScreen ? 1 : 2),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: fontSize,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected 
                      ? const Color(0xFF2196F3)
                      : isDark ? Colors.grey[300] : Colors.grey[700],
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
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, bool isDark, bool isSmallScreen, bool isVerySmallScreen) {
    final isSelected = currentIndex == index;
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = isVerySmallScreen ? 20.0 : (isSmallScreen ? 18.0 : 20.0);
    final fontSize = isVerySmallScreen ? 8.0 : (isSmallScreen ? 9.0 : 10.0);
    final horizontalPadding = isVerySmallScreen ? screenWidth * 0.01 : (isSmallScreen ? screenWidth * 0.008 : screenWidth * 0.012);
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isVerySmallScreen ? 6 : (isSmallScreen ? 4 : 6),
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          color: isSelected 
            ? const Color(0xFF2196F3).withOpacity(0.2)
            : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
                size: iconSize,
              color: isSelected 
                ? const Color(0xFF2196F3)
                : isDark ? Colors.grey[300] : Colors.grey[700],
            ),
              SizedBox(height: isVerySmallScreen ? 1 : 2),
              Flexible(
                child: Text(
              label,
              style: GoogleFonts.poppins(
                    fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected 
                  ? const Color(0xFF2196F3)
                  : isDark ? Colors.grey[300] : Colors.grey[700],
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
    );
  }
} 