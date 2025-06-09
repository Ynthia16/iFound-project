import 'package:flutter/material.dart';
import '../components/ifound_onboarding_page.dart';
import '../components/ifound_button.dart';
import '../components/ifound_background.dart';
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

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
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
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  width: _currentPage == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? const Color(0xFF2196F3) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _goToLogin,
                      child: const Text('Skip'),
                    ),
                    IFoundButton(
                      text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      width: 140,
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