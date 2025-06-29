import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdminNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 768;
    final sidebarWidth = isSmallScreen ? 200.0 : 250.0;
    
    return Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/ifound_logo.svg',
                  height: isSmallScreen ? 24 : 28,
                  width: isSmallScreen ? 24 : 28,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  index: 0,
                  isSmallScreen: isSmallScreen,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.people,
                  title: 'Users',
                  index: 1,
                  isSmallScreen: isSmallScreen,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.assignment,
                  title: 'Reports',
                  index: 2,
                  isSmallScreen: isSmallScreen,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.analytics,
                  title: 'Analytics',
                  index: 3,
                  isSmallScreen: isSmallScreen,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  index: 4,
                  isSmallScreen: isSmallScreen,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.history,
                  title: 'Audit Logs',
                  index: 5,
                  isSmallScreen: isSmallScreen,
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 8),
                if (!isSmallScreen)
                  Text(
                    'Admin Dashboard v1.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
    required bool isSmallScreen,
  }) {
    final isSelected = selectedIndex == index;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        title: isSmallScreen ? null : Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () => onItemSelected(index),
      ),
    );
  }
} 