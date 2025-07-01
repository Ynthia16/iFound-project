import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class IFoundNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const IFoundNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
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
              _buildNavItem(context, 0, Icons.home_rounded, 'Home'.tr(), isDark, isSmallScreen),
              _buildNavItem(context, 1, Icons.search_rounded, 'Report Lost'.tr(), isDark, isSmallScreen),
              _buildNavItem(context, 2, Icons.add_box_rounded, 'Report Found'.tr(), isDark, isSmallScreen),
              _buildNavItem(context, 3, Icons.star_rounded, 'Feedback'.tr(), isDark, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, bool isDark, bool isSmallScreen) {
    final isSelected = currentIndex == index;
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final fontSize = isSmallScreen ? 10.0 : 11.0;
    final horizontalPadding = isSmallScreen ? screenWidth * 0.01 : screenWidth * 0.015;
    
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: isSmallScreen ? 6 : 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
            SizedBox(height: isSmallScreen ? 1 : 2),
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
    );
  }
} 