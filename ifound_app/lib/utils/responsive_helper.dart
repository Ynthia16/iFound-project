import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 400;
  }

  static bool isVerySmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 350;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 && 
           MediaQuery.of(context).size.width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isVerySmallScreen(context)) {
      return const EdgeInsets.all(12.0);
    } else if (isSmallScreen(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isMobile(context)) {
      return const EdgeInsets.all(20.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  static double getFontSize(BuildContext context, double baseSize) {
    if (isVerySmallScreen(context)) {
      return baseSize * 0.9;
    } else if (isSmallScreen(context)) {
      return baseSize;
    } else if (isMobile(context)) {
      return baseSize * 1.05;
    } else if (isTablet(context)) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }

  static double getIconSize(BuildContext context, double baseSize) {
    if (isVerySmallScreen(context)) {
      return baseSize * 0.9;
    } else if (isSmallScreen(context)) {
      return baseSize;
    } else if (isMobile(context)) {
      return baseSize * 1.05;
    } else if (isTablet(context)) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }

  static double getSpacing(BuildContext context, double baseSpacing) {
    if (isVerySmallScreen(context)) {
      return baseSpacing * 0.8;
    } else if (isSmallScreen(context)) {
      return baseSpacing;
    } else if (isMobile(context)) {
      return baseSpacing * 1.1;
    } else if (isTablet(context)) {
      return baseSpacing * 1.2;
    } else {
      return baseSpacing * 1.5;
    }
  }

  static BorderRadius getBorderRadius(BuildContext context, double baseRadius) {
    if (isVerySmallScreen(context)) {
      return BorderRadius.circular(baseRadius * 0.9);
    } else if (isSmallScreen(context)) {
      return BorderRadius.circular(baseRadius);
    } else if (isMobile(context)) {
      return BorderRadius.circular(baseRadius * 1.05);
    } else if (isTablet(context)) {
      return BorderRadius.circular(baseRadius * 1.1);
    } else {
      return BorderRadius.circular(baseRadius * 1.2);
    }
  }

  static Widget responsiveWidget({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  static int getGridCrossAxisCount(BuildContext context) {
    if (isVerySmallScreen(context)) {
      return 1;
    } else if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  static double getMaxWidth(BuildContext context) {
    if (isVerySmallScreen(context)) {
      return double.infinity;
    } else if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 600;
    } else {
      return 800;
    }
  }

  // Mobile-specific helper methods
  static double getMobileButtonHeight(BuildContext context) {
    if (isVerySmallScreen(context)) {
      return 44.0;
    } else if (isSmallScreen(context)) {
      return 48.0;
    } else {
      return 52.0;
    }
  }

  static double getMobileIconSize(BuildContext context) {
    if (isVerySmallScreen(context)) {
      return 20.0;
    } else if (isSmallScreen(context)) {
      return 22.0;
    } else {
      return 24.0;
    }
  }

  static double getMobileFontSize(BuildContext context) {
    if (isVerySmallScreen(context)) {
      return 12.0;
    } else if (isSmallScreen(context)) {
      return 14.0;
    } else {
      return 16.0;
    }
  }
} 