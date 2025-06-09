import 'package:flutter/material.dart';
import '../components/ifound_appbar.dart';
import '../components/ifound_background.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = 'en';
  bool _pushNotifications = true;
  bool _showNameOnPosts = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return IFoundBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: IFoundAppBar(title: 'settings'.tr()),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.person_rounded, color: Color(0xFF2196F3)),
                title: const Text('Cynthia Uwase'),
                subtitle: const Text('cynthia@email.com'),
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('Edit'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: Column(
                children: [
                  SwitchListTile(
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (v) => themeProvider.setTheme(v ? ThemeMode.dark : ThemeMode.light),
                    title: Text('dark_mode'.tr()),
                    secondary: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.nightlight_round : Icons.wb_sunny_rounded, color: Color(0xFF2196F3)),
                  ),
                  const Divider(height: 0),
                  SwitchListTile(
                    value: _pushNotifications,
                    onChanged: (v) => setState(() => _pushNotifications = v),
                    title: const Text('Push Notifications'),
                    secondary: const Icon(Icons.notifications_rounded, color: Color(0xFF2196F3)),
                  ),
                  const Divider(height: 0),
                  SwitchListTile(
                    value: _showNameOnPosts,
                    onChanged: (v) => setState(() => _showNameOnPosts = v),
                    title: const Text('Show my name on posts'),
                    secondary: const Icon(Icons.visibility_rounded, color: Color(0xFF2196F3)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.language_rounded, color: Color(0xFF2196F3)),
                title: Text('language'.tr()),
                subtitle: DropdownButton<String>(
                  value: _language,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'fr', child: Text('Français')),
                    DropdownMenuItem(value: 'rw', child: Text('Kinyarwanda')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _language = v);
                      context.setLocale(Locale(v));
                    }
                  },
                  underline: Container(),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.privacy_tip_rounded, color: Color(0xFF2196F3)),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  // TODO: Show privacy policy
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 