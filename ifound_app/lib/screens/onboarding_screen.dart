import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/ifound_onboarding_page.dart';
import '../components/ifound_button.dart';
import '../components/ifound_background.dart';
import '../utils/responsive_helper.dart';
import 'login_screen.dart';

/// Swipeable onboarding flow for new users.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'asset': 'assets/ifound_logo.svg',
      'title': 'Welcome to iFound!',
      'subtitle': 'Lost or found a document? iFound connects you.',
    },
    {
      'asset': 'assets/ifound_logo.svg', // Replacing it  with a doc icon SVG
      'title': 'Report Lost or Found',
      'subtitle': 'Easily report lost or found documents in seconds.',
    },
    {
      'asset': 'assets/ifound_logo.svg', // Replacing it with a privacy icon SVG
      'title': 'Safe & Private',
      'subtitle': 'No direct contact. Your info is secure and private.',
    },
    {
      'asset': 'assets/ifound_logo.svg', // Replacing it  with a notify icon SVG
      'title': 'Get Notified',
      'subtitle': 'We will alert you if there is a match for your document.',
    },
  ];

  Future<void> _goToLogin() async {
    // Save that user has seen onboarding
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
    } catch (e) {
      // Failed to save onboarding status: $e
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    final cardMargin = isSmallScreen 
        ? const EdgeInsets.symmetric(vertical: 16, horizontal: 12)
        : const EdgeInsets.symmetric(vertical: 24, horizontal: 16);
    final cardPadding = isSmallScreen ? 20.0 : 32.0;
    final bottomPadding = isSmallScreen ? 16.0 : 24.0;
    final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
    final buttonWidth = isSmallScreen ? 120.0 : 160.0;

    return IFoundBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Center(
                      child: Card(
                        margin: cardMargin,
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        child: Padding(
                          padding: EdgeInsets.all(cardPadding),
                          child: IFoundOnboardingPage(
                            asset: page['asset']!,
                            title: page['title']!,
                            subtitle: page['subtitle']!,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                  width: _currentPage == index ? 20 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? const Color(0xFF2196F3) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                )),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: bottomPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _goToLogin,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16, 
                          vertical: isSmallScreen ? 8 : 12
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                      ),
                    ),
                    IFoundButton(
                      text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      width: buttonWidth,
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _goToLogin();
                        } else {
                          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}