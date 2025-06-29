import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SafetyGuidelines extends StatelessWidget {
  final bool showFullGuidelines;
  final VoidCallback? onClose;

  const SafetyGuidelines({
    super.key,
    this.showFullGuidelines = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Safety Guidelines'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Keep yourself and others safe'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                    iconSize: 20,
                  ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGuidelineItem(
                  icon: Icons.person_off_rounded,
                  title: 'Never share personal photos'.tr(),
                  description: 'For your safety, we do not allow document photos. Only share document details.'.tr(),
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                
                _buildGuidelineItem(
                  icon: Icons.location_off_rounded,
                  title: 'Be careful with location details'.tr(),
                  description: 'Share general area only, not exact addresses or personal locations.'.tr(),
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                
                _buildGuidelineItem(
                  icon: Icons.phone_disabled_rounded,
                  title: 'Use secure contact methods'.tr(),
                  description: 'Prefer in-app messaging over sharing personal phone numbers.'.tr(),
                  isDark: isDark,
                ),
                
                if (showFullGuidelines) ...[
                  const SizedBox(height: 16),
                  
                  _buildGuidelineItem(
                    icon: Icons.verified_user_rounded,
                    title: 'Verify before meeting'.tr(),
                    description: 'Always verify document details before arranging to meet someone.'.tr(),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildGuidelineItem(
                    icon: Icons.public_rounded,
                    title: 'Meet in public places'.tr(),
                    description: 'Choose busy, well-lit public locations for document exchanges.'.tr(),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildGuidelineItem(
                    icon: Icons.report_rounded,
                    title: 'Report suspicious activity'.tr(),
                    description: 'If something seems wrong, report it immediately through the app.'.tr(),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildGuidelineItem(
                    icon: Icons.emergency_rounded,
                    title: 'Emergency contacts'.tr(),
                    description: 'Keep emergency numbers handy: Police (112), Local authorities.'.tr(),
                    isDark: isDark,
                  ),
                ],
                
                // Warning section
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Colors.orange[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your safety is our priority. If you feel unsafe at any time, stop and contact authorities.'.tr(),
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2196F3),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Safety guidelines dialog
class SafetyGuidelinesDialog extends StatelessWidget {
  const SafetyGuidelinesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const SafetyGuidelines(showFullGuidelines: true),
    );
  }
}

// Safety guidelines bottom sheet
class SafetyGuidelinesBottomSheet extends StatelessWidget {
  const SafetyGuidelinesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Content
          const SafetyGuidelines(showFullGuidelines: true),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
} 