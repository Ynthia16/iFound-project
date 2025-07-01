import 'package:flutter/material.dart';
import '../components/ifound_appbar.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/safety_guidelines.dart';
import 'help_faq_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = 'en';
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _locationSharing = false;
  bool _dataAnalytics = true;
  bool _biometricAuth = false;
  bool _twoFactorAuth = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('selected_locale') ?? 'en';
    final pushNotifs = prefs.getBool('push_notifications') ?? true;
    final emailNotifs = prefs.getBool('email_notifications') ?? true;
    final locationShare = prefs.getBool('location_sharing') ?? false;
    final analytics = prefs.getBool('data_analytics') ?? true;
    final biometric = prefs.getBool('biometric_auth') ?? false;
    final twoFactor = prefs.getBool('two_factor_auth') ?? false;

    setState(() {
      _language = savedLocale;
      _pushNotifications = pushNotifs;
      _emailNotifications = emailNotifs;
      _locationSharing = locationShare;
      _dataAnalytics = analytics;
      _biometricAuth = biometric;
      _twoFactorAuth = twoFactor;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  Future<void> _changeLanguage(String languageCode) async {
    await _saveSetting('selected_locale', languageCode);

    setState(() {
      _language = languageCode;
    });

    if (mounted) {
      context.setLocale(Locale(languageCode));
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'rw':
        return 'Kinyarwanda';
      default:
        return 'English';
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'language'.tr(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language, size: 24),
              title: const Text('English', style: TextStyle(fontSize: 16)),
              trailing: _language == 'en'
                  ? const Icon(Icons.check, color: Colors.green, size: 24)
                  : null,
              onTap: () {
                Navigator.of(context).pop();
                _changeLanguage('en');
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            ListTile(
              leading: const Icon(Icons.language, size: 24),
              title: const Text('Français', style: TextStyle(fontSize: 16)),
              trailing: _language == 'fr'
                  ? const Icon(Icons.check, color: Colors.green, size: 24)
                  : null,
              onTap: () {
                Navigator.of(context).pop();
                _changeLanguage('fr');
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            ListTile(
              leading: const Icon(Icons.language, size: 24),
              title: const Text('Kinyarwanda', style: TextStyle(fontSize: 16)),
              trailing: _language == 'rw'
                  ? const Icon(Icons.check, color: Colors.green, size: 24)
                  : null,
              onTap: () {
                Navigator.of(context).pop();
                _changeLanguage('rw');
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'.tr(), style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('dark_mode'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.wb_sunny_rounded),
              title: Text('Light Mode'.tr()),
              subtitle: Text('Use light theme'.tr()),
              trailing: themeProvider.themeMode == ThemeMode.light
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                Navigator.of(context).pop();
                themeProvider.setTheme(ThemeMode.light);
              },
            ),
            ListTile(
              leading: const Icon(Icons.nightlight_round),
              title: Text('Dark Mode'.tr()),
              subtitle: Text('Use dark theme'.tr()),
              trailing: themeProvider.themeMode == ThemeMode.dark
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                Navigator.of(context).pop();
                themeProvider.setTheme(ThemeMode.dark);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_system_daydream_rounded),
              title: Text('System Default'.tr()),
              subtitle: Text('Follow system settings'.tr()),
              trailing: themeProvider.themeMode == ThemeMode.system
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                Navigator.of(context).pop();
                themeProvider.setTheme(ThemeMode.system);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'.tr()),
          ),
        ],
      ),
    );
  }

  void _showPrivacyAndSafetyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy & Safety'.tr()),
        content: SingleChildScrollView(
          child: SafetyGuidelines(showFullGuidelines: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Data export started. You will receive an email shortly.'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to export data. Please try again.'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() => _isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.delete();
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to delete account. Please try again.'),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final padding = isSmallScreen ? 16.0 : 20.0;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FA),
      appBar: IFoundAppBar(
        title: 'settings'.tr(),
        showLogo: false,
        showBackButton: true,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading settings...'.tr(),
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Language & Region'.tr(), isSmallScreen),
                  _buildSettingTile(
                    icon: Icons.language_rounded,
                    title: 'language'.tr(),
                    subtitle: _getLanguageName(_language),
                    onTap: _showLanguageDialog,
                    isDark: isDark,
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  _buildSettingTile(
                    icon: Icons.palette_rounded,
                    title: 'dark_mode'.tr(),
                    subtitle: 'Customize app appearance'.tr(),
                    onTap: _showThemeDialog,
                    isDark: isDark,
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  _buildSectionHeader('Notifications'.tr(), isSmallScreen),
                  SwitchListTile(
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() => _pushNotifications = value);
                      _saveSetting('push_notifications', value);
                    },
                    title: Text(
                      'Push Notifications'.tr(),
                      style: TextStyle(fontSize: isSmallScreen ? 15 : 16),
                    ),
                    subtitle: Text(
                      'Receive app notifications'.tr(),
                      style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                    ),
                    secondary: Icon(
                      Icons.notifications_rounded,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    activeColor: const Color(0xFF2196F3),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                  ),
                  SwitchListTile(
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() => _emailNotifications = value);
                      _saveSetting('email_notifications', value);
                    },
                    title: Text(
                      'Email Notifications'.tr(),
                      style: TextStyle(fontSize: isSmallScreen ? 15 : 16),
                    ),
                    subtitle: Text(
                      'Receive email updates'.tr(),
                      style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                    ),
                    secondary: Icon(
                      Icons.email_rounded,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    activeColor: const Color(0xFF2196F3),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  _buildSectionHeader('Privacy & Safety'.tr(), isSmallScreen),
                  SwitchListTile(
                    value: _locationSharing,
                    onChanged: (value) {
                      setState(() => _locationSharing = value);
                      _saveSetting('location_sharing', value);
                    },
                    title: Text(
                      'Location Sharing'.tr(),
                      style: TextStyle(fontSize: isSmallScreen ? 15 : 16),
                    ),
                    subtitle: Text(
                      'Share location in reports'.tr(),
                      style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                    ),
                    secondary: Icon(
                      Icons.location_on_rounded,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    activeColor: const Color(0xFF2196F3),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                  ),
                  SwitchListTile(
                    value: _dataAnalytics,
                    onChanged: (value) {
                      setState(() => _dataAnalytics = value);
                      _saveSetting('data_analytics', value);
                    },
                    title: Text(
                      'Data Analytics'.tr(),
                      style: TextStyle(fontSize: isSmallScreen ? 15 : 16),
                    ),
                    subtitle: Text(
                      'Help improve the app'.tr(),
                      style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                    ),
                    secondary: Icon(
                      Icons.analytics_rounded,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    activeColor: const Color(0xFF2196F3),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  _buildSettingTile(
                    icon: Icons.security_rounded,
                    title: 'Privacy & Safety'.tr(),
                    subtitle: 'View safety guidelines'.tr(),
                    onTap: _showPrivacyAndSafetyDialog,
                    isDark: isDark,
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  _buildSectionHeader('Security'.tr(), isSmallScreen),
                  SwitchListTile(
                    value: _biometricAuth,
                    onChanged: (value) {
                      setState(() => _biometricAuth = value);
                      _saveSetting('biometric_auth', value);
                    },
                    title: Text(
                      'Biometric Authentication'.tr(),
                      style: TextStyle(fontSize: isSmallScreen ? 15 : 16),
                    ),
                    subtitle: Text(
                      'Use fingerprint or face ID'.tr(),
                      style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                    ),
                    secondary: Icon(
                      Icons.fingerprint_rounded,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    activeColor: const Color(0xFF2196F3),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                  ),
                  SwitchListTile(
                    value: _twoFactorAuth,
                    onChanged: (value) {
                      setState(() => _twoFactorAuth = value);
                      _saveSetting('two_factor_auth', value);
                    },
                    title: Text(
                      'Two-Factor Authentication'.tr(),
                      style: TextStyle(fontSize: isSmallScreen ? 15 : 16),
                    ),
                    subtitle: Text(
                      'Add extra security layer'.tr(),
                      style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                    ),
                    secondary: Icon(
                      Icons.security_rounded,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    activeColor: const Color(0xFF2196F3),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  _buildSectionHeader('Support & Help'.tr(), isSmallScreen),
                  _buildSettingTile(
                    icon: Icons.help_rounded,
                    title: 'Help & FAQ'.tr(),
                    subtitle: 'Get help and answers'.tr(),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpFAQScreen(),
                      ),
                    ),
                    isDark: isDark,
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  _buildSectionHeader('Data Management'.tr(), isSmallScreen),
                  _buildSettingTile(
                    icon: Icons.download_rounded,
                    title: 'Export Data'.tr(),
                    subtitle: 'Download your data'.tr(),
                    onTap: _exportData,
                    isDark: isDark,
                    isSmallScreen: isSmallScreen,
                  ),
                  _buildSettingTile(
                    icon: Icons.delete_forever_rounded,
                    title: 'Delete Account'.tr(),
                    subtitle: 'Permanently delete account'.tr(),
                    onTap: _deleteAccount,
                    isDark: isDark,
                    isSmallScreen: isSmallScreen,
                    isDestructive: true,
                  ),
                  SizedBox(height: isSmallScreen ? 30 : 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12, top: isSmallScreen ? 6 : 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isSmallScreen ? 16 : 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2196F3),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
    bool isSmallScreen = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF2196F3),
          size: isSmallScreen ? 20 : 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 15 : 16,
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : (isDark ? Colors.white : Colors.black87),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF2196F3),
          size: 20,
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 8 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
} 