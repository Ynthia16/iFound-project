import 'package:flutter/material.dart';
import '../components/ifound_appbar.dart';
import '../components/ifound_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class HelpFAQScreen extends StatefulWidget {
  const HelpFAQScreen({super.key});

  @override
  State<HelpFAQScreen> createState() => _HelpFAQScreenState();
}

class _HelpFAQScreenState extends State<HelpFAQScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';
  bool _showSearchResults = false;

  // FAQ Categories
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'all',
      'title': 'All Questions',
      'icon': Icons.all_inclusive_rounded,
    },
    {
      'id': 'getting-started',
      'title': 'Getting Started',
      'icon': Icons.rocket_launch_rounded,
    },
    {
      'id': 'reporting',
      'title': 'Reporting Documents',
      'icon': Icons.description_rounded,
    },
    {
      'id': 'safety',
      'title': 'Safety & Privacy',
      'icon': Icons.security_rounded,
    },
    {
      'id': 'notifications',
      'title': 'Notifications',
      'icon': Icons.notifications_rounded,
    },
    {
      'id': 'search',
      'title': 'Search & Filters',
      'icon': Icons.search_rounded,
    },
    {
      'id': 'account',
      'title': 'Account & Settings',
      'icon': Icons.person_rounded,
    },
    {
      'id': 'troubleshooting',
      'title': 'Troubleshooting',
      'icon': Icons.help_rounded,
    },
  ];

  // FAQ Data
  final List<Map<String, dynamic>> _faqData = [
    // Getting Started
    {
      'category': 'getting-started',
      'question': 'What is iFound?',
      'answer': 'iFound is a community-driven platform that helps people find lost documents and return them to their rightful owners. It connects people who have lost documents with those who have found them.',
    },
    {
      'category': 'getting-started',
      'question': 'How do I create an account?',
      'answer': 'You can create an account using your email and password, or sign in with your Google account for a faster experience. Simply tap "Register" on the login screen.',
    },
    {
      'category': 'getting-started',
      'question': 'Is iFound free to use?',
      'answer': 'Yes, iFound is completely free to use. We believe in helping communities without any cost barriers.',
    },
    {
      'category': 'getting-started',
      'question': 'What languages does iFound support?',
      'answer': 'iFound currently supports English, French, and Kinyarwanda. You can change the language in Settings.',
    },

    // Reporting Documents
    {
      'category': 'reporting',
      'question': 'How do I report a lost document?',
      'answer': 'Tap "Report Lost" on the home screen, fill in the document details (name, type, location), and submit. We\'ll notify you if someone finds it.',
    },
    {
      'category': 'reporting',
      'question': 'How do I report a found document?',
      'answer': 'Tap "Report Found" on the home screen, enter the document details, and submit. The owner will be notified automatically.',
    },
    {
      'category': 'reporting',
      'question': 'What document types can I report?',
      'answer': 'You can report National IDs, Passports, Driver Licenses, Student IDs, Bank Cards, Insurance Cards, Medical Cards, Academic Certificates, Birth Certificates, Marriage Certificates, and other documents.',
    },
    {
      'category': 'reporting',
      'question': 'Why can\'t I upload a photo of the document?',
      'answer': 'For your safety and privacy, we don\'t allow document photos. This prevents misuse of personal information and keeps everyone safe.',
    },
    {
      'category': 'reporting',
      'question': 'How accurate does the name need to be?',
      'answer': 'The name should match exactly as it appears on the document. This helps ensure accurate matches and prevents false notifications.',
    },
    {
      'category': 'reporting',
      'question': 'Can I edit or delete my report?',
      'answer': 'Currently, you cannot edit reports after submission. If you need to make changes, please contact support or create a new report.',
    },

    // Safety & Privacy
    {
      'category': 'safety',
      'question': 'How does iFound protect my privacy?',
      'answer': 'We never share your personal information. Only document details are shared for matching purposes. Your contact information remains private.',
    },
    {
      'category': 'safety',
      'question': 'What should I do when meeting someone to exchange a document?',
      'answer': 'Always meet in public, well-lit places. Verify the document details before meeting. If something feels wrong, don\'t proceed and report it.',
    },
    {
      'category': 'safety',
      'question': 'How do I report suspicious activity?',
      'answer': 'If you encounter suspicious behavior, report it immediately through the app or contact local authorities. Your safety is our priority.',
    },
    {
      'category': 'safety',
      'question': 'Is my location shared with others?',
      'answer': 'Only general area information (sector/district) is shared, never exact addresses. This helps with matching while protecting your privacy.',
    },

    // Notifications
    {
      'category': 'notifications',
      'question': 'When will I receive notifications?',
      'answer': 'You\'ll receive notifications when someone reports a document that matches yours, or when there are important updates about your reports.',
    },
    {
      'category': 'notifications',
      'question': 'How do I manage my notification preferences?',
      'answer': 'Go to Settings > Notifications to control push notifications and email notifications. You can enable/disable them anytime.',
    },
    {
      'category': 'notifications',
      'question': 'Why am I not receiving notifications?',
      'answer': 'Check your device notification settings and app permissions. Also ensure notifications are enabled in the app settings.',
    },

    // Search & Filters
    {
      'category': 'search',
      'question': 'How do I search for documents?',
      'answer': 'Use the Search tab to find documents. You can filter by status (lost/found), document type, location, and date range.',
    },
    {
      'category': 'search',
      'question': 'Can I search by partial names?',
      'answer': 'Currently, exact name matching is required for security reasons. This ensures accurate matches and prevents privacy issues.',
    },
    {
      'category': 'search',
      'question': 'How do the advanced filters work?',
      'answer': 'Advanced filters let you narrow down results by document type, location, date range, and status. This helps you find specific documents quickly.',
    },

    // Account & Settings
    {
      'category': 'account',
      'question': 'How do I change my password?',
      'answer': 'Go to Settings > Security to change your password. If you forgot your password, use the "Forgot Password" option on the login screen.',
    },
    {
      'category': 'account',
      'question': 'Can I use iFound offline?',
      'answer': 'Yes! You can create reports offline. They\'ll be synced automatically when you\'re back online.',
    },
    {
      'category': 'account',
      'question': 'How do I delete my account?',
      'answer': 'Go to Settings > Delete Account. This action cannot be undone and will permanently remove all your data.',
    },
    {
      'category': 'account',
      'question': 'How do I change the app theme?',
      'answer': 'Go to Settings > Appearance to choose between Light, Dark, or System default theme.',
    },

    // Troubleshooting
    {
      'category': 'troubleshooting',
      'question': 'The app is not loading properly',
      'answer': 'Try closing and reopening the app. If the problem persists, check your internet connection and try again.',
    },
    {
      'category': 'troubleshooting',
      'question': 'I can\'t submit a report',
      'answer': 'Make sure all required fields are filled correctly. Check your internet connection. If the problem continues, try restarting the app.',
    },
    {
      'category': 'troubleshooting',
      'question': 'My notifications aren\'t working',
      'answer': 'Check your device settings, app permissions, and notification preferences in the app settings.',
    },
    {
      'category': 'troubleshooting',
      'question': 'How do I contact support?',
      'answer': 'You can contact us through the feedback section in the app, or email us at support@ifound.rw',
    },
  ];

  List<Map<String, dynamic>> get _filteredFAQs {
    List<Map<String, dynamic>> filtered = _faqData;

    // Filter by category
    if (_selectedCategory != 'all') {
      filtered = filtered.where((faq) => faq['category'] == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((faq) {
        final question = faq['question'].toString().toLowerCase();
        final answer = faq['answer'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return question.contains(query) || answer.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    
    return IFoundBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: IFoundAppBar(
          title: 'Help & FAQ'.tr(),
          showLogo: true,
          showBackButton: true,
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search questions...'.tr(),
                  prefixIcon: const Icon(Icons.search_rounded, size: 24),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(width: 2, color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(width: 2, color: Color(0xFF2196F3)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                    _showSearchResults = value.isNotEmpty;
                  });
                },
              ),
            ),
            
            // Categories
            if (!_showSearchResults) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Categories'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category['id'];
                    
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category['id'];
                          });
                        },
                        child: Card(
                          elevation: isSelected ? 4 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: isSelected 
                            ? const Color(0xFF2196F3) 
                            : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  category['icon'],
                                  color: isSelected ? Colors.white : const Color(0xFF2196F3),
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category['title'].tr(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : null,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            // FAQ List
            Expanded(
              child: _filteredFAQs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No questions found for "$_searchQuery"'.tr()
                                : 'No questions in this category'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredFAQs.length,
                      itemBuilder: (context, index) {
                        final faq = _filteredFAQs[index];
                        return _buildFAQItem(faq, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq, bool isDark) {
    return ExpansionTile(
      title: Text(
        faq['question'],
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            faq['answer'],
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}