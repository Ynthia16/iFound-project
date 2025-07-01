import 'package:flutter/material.dart';
import '../components/ifound_logo.dart';
import '../utils/responsive_helper.dart';
import 'onboarding_screen.dart';
import 'package:google_fonts/google_fonts.dart';

/// Splash screen with logo and tagline.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    
    // Responsive sizing
    final logoSize = isSmallScreen ? 100.0 : 140.0;
    final titleFontSize = isSmallScreen ? 20.0 : 24.0;
    final subtitleFontSize = isSmallScreen ? 14.0 : 16.0;
    final spacing = isSmallScreen ? 24.0 : 40.0;
    final smallSpacing = isSmallScreen ? 12.0 : 16.0;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IFoundLogo(size: logoSize),
              SizedBox(height: spacing),
              Text(
                'Lost it? iFound it.',
                style: GoogleFonts.poppins(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: smallSpacing),
              Text(
                'Community-driven document recovery',
                style: GoogleFonts.poppins(
                  fontSize: subtitleFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 