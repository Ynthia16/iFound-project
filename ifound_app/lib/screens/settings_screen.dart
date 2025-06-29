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
  bool _showNameOnPosts = false;
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
    final showName = prefs.getBool('show_name_on_posts') ?? false;
    final emailNotifs = prefs.getBool('email_notifications') ?? true;
    final locationShare = prefs.getBool('location_sharing') ?? false;
    final analytics = prefs.getBool('data_analytics') ?? true;
    final biometric = prefs.getBool('biometric_auth') ?? false;
    final twoFactor = prefs.getBool('two_factor_auth') ?? false;

    setState(() {
      _language = savedLocale;
      _pushNotifications = pushNotifs;
      _showNameOnPosts = showName;
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

    context.setLocale(Locale(languageCode));
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

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              value: _biometricAuth,
              onChanged: (value) async {
                setState(() => _biometricAuth = value);
                await _saveSetting('biometric_auth', value);
                Navigator.of(context).pop();
              },
              title: const Text('Biometric Authentication'),
              subtitle: const Text('Use fingerprint or face ID'),
              secondary: const Icon(Icons.fingerprint_rounded),
            ),
            SwitchListTile(
              value: _twoFactorAuth,
              onChanged: (value) async {
                setState(() => _twoFactorAuth = value);
                await _saveSetting('two_factor_auth', value);
                Navigator.of(context).pop();
              },
              title: const Text('Two-Factor Authentication'),
              subtitle: const Text('Add extra security layer'),
              secondary: const Icon(Icons.security_rounded),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              value: _locationSharing,
              onChanged: (value) async {
                setState(() => _locationSharing = value);
                await _saveSetting('location_sharing', value);
                Navigator.of(context).pop();
              },
              title: const Text('Location Sharing'),
              subtitle: const Text('Share your location in reports'),
              secondary: const Icon(Icons.location_on_rounded),
            ),
            SwitchListTile(
              value: _dataAnalytics,
              onChanged: (value) async {
                setState(() => _dataAnalytics = value);
                await _saveSetting('data_analytics', value);
                Navigator.of(context).pop();
              },
              title: const Text('Data Analytics'),
              subtitle: const Text('Help improve the app'),
              secondary: const Icon(Icons.analytics_rounded),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
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

  void _showAccessibilityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Accessibility Settings'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              value: false, // TODO: Add accessibility settings
              onChanged: (value) {
                // TODO: Implement accessibility features
              },
              title: Text('High Contrast Mode'.tr()),
              subtitle: Text('Use high contrast colors'.tr()),
              secondary: const Icon(Icons.contrast_rounded),
            ),
            SwitchListTile(
              value: false, // TODO: Add accessibility settings
              onChanged: (value) {
                // TODO: Implement accessibility features
              },
              title: Text('Large Text'.tr()),
              subtitle: Text('Make text larger'.tr()),
              secondary: const Icon(Icons.text_fields_rounded),
            ),
            SwitchListTile(
              value: false, // TODO: Add accessibility settings
              onChanged: (value) {
                // TODO: Implement accessibility features
              },
              title: Text('Screen Reader Support'.tr()),
              subtitle: Text('Support screen readers'.tr()),
              secondary: const Icon(Icons.hearing_rounded),
            ),
          ],
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
        // Export user data logic here
        await Future.delayed(const Duration(seconds: 2)); // Simulate export

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Data export started. You will receive an email shortly.'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
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
              content:
                  const Text('Failed to delete account. Please try again.'),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Section
                  _buildSectionHeader('Account Settings'.tr(), Icons.person_rounded, isDark),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.language_rounded,
                        title: 'language'.tr(),
                        subtitle: _getLanguageName(_language),
                        onTap: _showLanguageDialog,
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildSettingsTile(
                        icon: Icons.dark_mode_rounded,
                        title: 'dark_mode'.tr(),
                        subtitle: 'Customize app appearance'.tr(),
                        onTap: _showThemeDialog,
                        isDark: isDark,
                      ),
                    ],
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notifications Section
                  _buildSectionHeader('Notifications'.tr(), Icons.notifications_rounded, isDark),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.notifications_active_rounded,
                        title: 'Push Notifications'.tr(),
                        subtitle: 'Receive app notifications'.tr(),
                        value: _pushNotifications,
                        onChanged: (value) async {
                          setState(() => _pushNotifications = value);
                          await _saveSetting('push_notifications', value);
                        },
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildSwitchTile(
                        icon: Icons.email_rounded,
                        title: 'Email Notifications'.tr(),
                        subtitle: 'Receive email updates'.tr(),
                        value: _emailNotifications,
                        onChanged: (value) async {
                          setState(() => _emailNotifications = value);
                          await _saveSetting('email_notifications', value);
                        },
                        isDark: isDark,
                      ),
                    ],
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Privacy & Safety Section
                  _buildSectionHeader('Privacy & Safety'.tr(), Icons.security_rounded, isDark),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.privacy_tip_rounded,
                        title: 'Privacy & Safety Guidelines'.tr(),
                        subtitle: 'View safety guidelines'.tr(),
                        onTap: _showPrivacyAndSafetyDialog,
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildSwitchTile(
                        icon: Icons.location_on_rounded,
                        title: 'Location Sharing'.tr(),
                        subtitle: 'Share location in reports'.tr(),
                        value: _locationSharing,
                        onChanged: (value) async {
                          setState(() => _locationSharing = value);
                          await _saveSetting('location_sharing', value);
                        },
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildSwitchTile(
                        icon: Icons.analytics_rounded,
                        title: 'Data Analytics'.tr(),
                        subtitle: 'Help improve the app'.tr(),
                        value: _dataAnalytics,
                        onChanged: (value) async {
                          setState(() => _dataAnalytics = value);
                          await _saveSetting('data_analytics', value);
                        },
                        isDark: isDark,
                      ),
                    ],
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Security Section
                  _buildSectionHeader('Security'.tr(), Icons.lock_rounded, isDark),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.fingerprint_rounded,
                        title: 'Biometric Authentication'.tr(),
                        subtitle: 'Use fingerprint or face ID'.tr(),
                        value: _biometricAuth,
                        onChanged: (value) async {
                          setState(() => _biometricAuth = value);
                          await _saveSetting('biometric_auth', value);
                        },
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildSwitchTile(
                        icon: Icons.security_rounded,
                        title: 'Two-Factor Authentication'.tr(),
                        subtitle: 'Add extra security layer'.tr(),
                        value: _twoFactorAuth,
                        onChanged: (value) async {
                          setState(() => _twoFactorAuth = value);
                          await _saveSetting('two_factor_auth', value);
                        },
                        isDark: isDark,
                      ),
                    ],
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Help & Support Section
                  _buildSectionHeader('Help & Support'.tr(), Icons.help_rounded, isDark),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & FAQ'.tr(),
                        subtitle: 'Get help and answers'.tr(),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HelpFAQScreen(),
                            ),
                          );
                        },
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildSettingsTile(
                        icon: Icons.accessibility_rounded,
                        title: 'Accessibility'.tr(),
                        subtitle: 'Customize accessibility options'.tr(),
                        onTap: _showAccessibilityDialog,
                        isDark: isDark,
                      ),
                    ],
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Data Management Section
                  _buildSectionHeader('Data Management'.tr(), Icons.storage_rounded, isDark),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.download_rounded,
                        title: 'Export Data'.tr(),
                        subtitle: 'Download your data'.tr(),
                        onTap: _exportData,
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildSettingsTile(
                        icon: Icons.delete_forever_rounded,
                        title: 'Delete Account'.tr(),
                        subtitle: 'Permanently delete your account'.tr(),
                        onTap: _deleteAccount,
                        isDark: isDark,
                        isDestructive: true,
                      ),
                    ],
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDark ? Colors.white70 : const Color(0xFF2196F3),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({required List<Widget> children, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF404040) : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive 
            ? Colors.red.withOpacity(0.1)
            : (isDark ? const Color(0xFF2196F3).withOpacity(0.1) : const Color(0xFFE3F2FD)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive 
            ? Colors.red 
            : (isDark ? const Color(0xFF2196F3) : const Color(0xFF1976D2)),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive 
            ? Colors.red 
            : (isDark ? Colors.white : Colors.black87),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: isDark ? Colors.white54 : Colors.grey[400],
        size: 16,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2196F3).withOpacity(0.1) : const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDark ? const Color(0xFF2196F3) : const Color(0xFF1976D2),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF2196F3),
        activeTrackColor: const Color(0xFF2196F3).withOpacity(0.3),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? const Color(0xFF404040) : Colors.grey[200],
      indent: 56,
      endIndent: 16,
    );
  }
}
