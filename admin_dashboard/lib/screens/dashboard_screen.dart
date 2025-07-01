import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/dashboard_overview.dart';
import '../widgets/admin_navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;

  final List<Widget> _screens = [
    const DashboardOverview(),
    const UsersManagementScreen(),
    const ReportsManagementScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
    const AuditLogsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 768;

    // Auto-collapse sidebar on small screens
    if (isSmallScreen && !_isSidebarCollapsed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isSidebarCollapsed = true;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('iFound Admin Dashboard'),
        leading: isSmallScreen ? IconButton(
          icon: Icon(_isSidebarCollapsed ? Icons.menu : Icons.close),
          onPressed: () {
            setState(() {
              _isSidebarCollapsed = !_isSidebarCollapsed;
            });
          },
        ) : null,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => themeProvider.toggleTheme(),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Provider.of<AuthProvider>(context, listen: false).signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Navigation Sidebar
          if (!_isSidebarCollapsed || !isSmallScreen)
            AdminNavigation(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                  // Auto-collapse sidebar on small screens after selection
                  if (isSmallScreen) {
                    _isSidebarCollapsed = true;
                  }
                });
              },
            ),
          // Main Content
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

// Enhanced Users Management Screen
class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _roleFilter = 'all';
  final Set<String> _selectedUsers = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesSearch = user['name']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
                            user['email']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true;

        final matchesRole = _roleFilter == 'all' ||
                           (_roleFilter == 'admin' && (user['isAdmin'] == true || user['role'] == 'admin')) ||
                           (_roleFilter == 'user' && user['isAdmin'] != true && user['role'] != 'admin');

        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  Future<void> _deleteUser(String userId) async {
    try {
      // Getting user details before deletion for audit log
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      await _firestore.collection('users').doc(userId).delete();

      // Creating audit log entry
      await _firestore.collection('audit_logs').add({
        'adminId': 'current_admin',
        'adminName': 'Admin User',
        'action': 'delete_user',
        'description': 'Deleted user: ${userData?['email'] ?? 'Unknown'}',
        'timestamp': FieldValue.serverTimestamp(),
        'targetId': userId,
        'targetType': 'user',
        'targetData': userData,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully'), backgroundColor: Colors.green),
      );
      _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _changeUserRole(String userId, bool isAdmin) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isAdmin': isAdmin,
        'role': isAdmin ? 'admin' : 'user',
      });

      // Creating audit log entry
      await _firestore.collection('audit_logs').add({
        'adminId': 'current_admin', //  get from auth
        'adminName': 'Admin User', //  get from auth
        'action': 'change_role',
        'description': 'Changed user role to ${isAdmin ? 'Admin' : 'User'}',
        'timestamp': FieldValue.serverTimestamp(),
        'targetId': userId,
        'targetType': 'user',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User role changed to ${isAdmin ? 'Admin' : 'User'}'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error changing role: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details: ${user['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user['email']}'),
            Text('Role: ${(user['isAdmin'] == true || user['role'] == 'admin') ? 'Admin' : 'User'}'),
            Text('Joined: ${_formatDate(user['createdAt'])}'),
            if (user['lastLogin'] != null)
              Text('Last Login: ${_formatDate(user['lastLogin'])}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'Unknown';
  }

  Future<void> _exportUsers() async {
    // Simple CSV export simulation
    _filteredUsers.map((user) {
      return '${user['name']},${user['email']},${(user['isAdmin'] == true || user['role'] == 'admin') ? 'Admin' : 'User'},${_formatDate(user['createdAt'])}';
    }).join('\n');

    // Later, I'd save this to a file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Users exported successfully'), backgroundColor: Colors.green),
    );
  }

  Future<void> _bulkDeleteUsers() async {
    if (_selectedUsers.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Bulk Delete'),
        content: Text('Are you sure you want to delete ${_selectedUsers.length} users?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        for (final userId in _selectedUsers) {
          await _deleteUser(userId);
        }
        setState(() {
          _selectedUsers.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedUsers.length} users deleted successfully'), backgroundColor: Colors.green),
        );
        _loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting users: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Users Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  if (_selectedUsers.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: _bulkDeleteUsers,
                      icon: const Icon(Icons.delete),
                      label: Text('Delete ${_selectedUsers.length}'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _exportUsers,
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _loadUsers,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh Users',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search and filters
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _roleFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Roles')),
                  DropdownMenuItem(value: 'admin', child: Text('Admins Only')),
                  DropdownMenuItem(value: 'user', child: Text('Users Only')),
                ],
                onChanged: (value) {
                  setState(() {
                    _roleFilter = value!;
                  });
                  _applyFilters();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text('Total Users: ${_filteredUsers.length}', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_filteredUsers.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No users found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: [
                      const DataColumn(label: Text('Select')),
                      const DataColumn(label: Text('Name')),
                      const DataColumn(label: Text('Email')),
                      const DataColumn(label: Text('Role')),
                      const DataColumn(label: Text('Joined')),
                      const DataColumn(label: Text('Actions')),
                    ],
                    rows: _filteredUsers.map((user) {
                      final createdAt = user['createdAt'] as Timestamp?;
                      final joinedDate = createdAt?.toDate() ?? DateTime.now();
                      final isSelected = _selectedUsers.contains(user['id']);

                      return DataRow(
                        selected: isSelected,
                        cells: [
                          DataCell(
                            Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedUsers.add(user['id']);
                                  } else {
                                    _selectedUsers.remove(user['id']);
                                  }
                                });
                              },
                            ),
                          ),
                          DataCell(Text(user['name'] ?? 'Unknown')),
                          DataCell(Text(user['email'] ?? 'No email')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (user['isAdmin'] == true || user['role'] == 'admin')
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    (user['isAdmin'] == true || user['role'] == 'admin')
                                        ? Icons.admin_panel_settings
                                        : Icons.person,
                                    size: 14,
                                    color: (user['isAdmin'] == true || user['role'] == 'admin')
                                        ? Colors.blue[700]
                                        : Colors.green[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    (user['isAdmin'] == true || user['role'] == 'admin') ? 'Admin' : 'User',
                                    style: TextStyle(
                                      color: (user['isAdmin'] == true || user['role'] == 'admin')
                                          ? Colors.blue[700]
                                          : Colors.green[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(Text('${joinedDate.day}/${joinedDate.month}/${joinedDate.year}')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _showUserDetails(user),
                                  icon: const Icon(Icons.info, size: 16),
                                  tooltip: 'View Details',
                                ),
                                IconButton(
                                  onPressed: () => _changeUserRole(
                                    user['id'],
                                    !(user['isAdmin'] == true || user['role'] == 'admin'),
                                  ),
                                  icon: const Icon(Icons.swap_horiz, size: 16),
                                  tooltip: 'Change Role',
                                ),
                                IconButton(
                                  onPressed: () => _deleteUser(user['id']),
                                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                  tooltip: 'Delete User',
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Enhanced Reports Management Screen
class ReportsManagementScreen extends StatefulWidget {
  const ReportsManagementScreen({super.key});

  @override
  State<ReportsManagementScreen> createState() => _ReportsManagementScreenState();
}

class _ReportsManagementScreenState extends State<ReportsManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> _filteredReports = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _typeFilter = 'all';
  final Set<String> _selectedReports = {};

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final snapshot = await _firestore.collection('reports').orderBy('timestamp', descending: true).get();
      final reports = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _reports = reports;
        _filteredReports = reports;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredReports = _reports.where((report) {
        final matchesSearch = report['name']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
                            report['institution']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true;

        final matchesStatus = _statusFilter == 'all' || report['status'] == _statusFilter;
        final matchesType = _typeFilter == 'all' || report['docType'] == _typeFilter;

        return matchesSearch && matchesStatus && matchesType;
      }).toList();
    });
  }

  Future<void> _deleteReport(String reportId) async {
    try {
      // Get report details before deletion for audit log
      final reportDoc = await _firestore.collection('reports').doc(reportId).get();
      final reportData = reportDoc.data();

      await _firestore.collection('reports').doc(reportId).delete();

      // Create audit log entry
      await _firestore.collection('audit_logs').add({
        'adminId': 'current_admin', // In a real app, get from auth
        'adminName': 'Admin User', // In a real app, get from auth
        'action': 'delete_report',
        'description': 'Deleted report: ${reportData?['name'] ?? 'Unknown'} - ${reportData?['institution'] ?? 'Unknown'}',
        'timestamp': FieldValue.serverTimestamp(),
        'targetId': reportId,
        'targetType': 'report',
        'targetData': reportData,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report deleted successfully'), backgroundColor: Colors.green),
      );
      _loadReports();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting report: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _markAsResolved(String reportId) async {
    try {
      // Get report details before status change for audit log
      final reportDoc = await _firestore.collection('reports').doc(reportId).get();
      final reportData = reportDoc.data();

      await _firestore.collection('reports').doc(reportId).update({
        'status': 'resolved',
        'resolvedAt': FieldValue.serverTimestamp(),
      });

      // Create audit log entry
      await _firestore.collection('audit_logs').add({
        'adminId': 'current_admin', // In a real app, get from auth
        'adminName': 'Admin User', // In a real app, get from auth
        'action': 'mark_resolved',
        'description': 'Marked report as resolved: ${reportData?['name'] ?? 'Unknown'} - ${reportData?['institution'] ?? 'Unknown'}',
        'timestamp': FieldValue.serverTimestamp(),
        'targetId': reportId,
        'targetType': 'report',
        'targetData': reportData,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report marked as resolved'), backgroundColor: Colors.green),
      );
      _loadReports();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating report: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showReportDetails(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Details: ${report['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${report['docType']}'),
            Text('Status: ${report['status']?.toString().toUpperCase()}'),
            Text('Institution: ${report['institution']}'),
            Text('Sector: ${report['sector']}'),
            Text('Date: ${_formatDate(report['timestamp'])}'),
            if (report['userId'] != null)
              Text('User ID: ${report['userId']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _contactUser(String userId) {
    // In a real app, this would open email or messaging
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contact feature for user $userId would open here'), backgroundColor: Colors.blue),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'Unknown';
  }

  Future<void> _exportReports() async {
    // Simple CSV export simulation
    _filteredReports.map((report) {
      return '${report['name']},${report['docType']},${report['status']},${report['institution']},${_formatDate(report['timestamp'])}';
    }).join('\n');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reports exported successfully'), backgroundColor: Colors.green),
    );
  }

  Future<void> _bulkDeleteReports() async {
    if (_selectedReports.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Bulk Delete'),
        content: Text('Are you sure you want to delete ${_selectedReports.length} reports?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        for (final reportId in _selectedReports) {
          await _deleteReport(reportId);
        }
        setState(() {
          _selectedReports.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedReports.length} reports deleted successfully'), backgroundColor: Colors.green),
        );
        _loadReports();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting reports: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reports Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  if (_selectedReports.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: _bulkDeleteReports,
                      icon: const Icon(Icons.delete),
                      label: Text('Delete ${_selectedReports.length}'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _exportReports,
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _loadReports,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh Reports',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search and filters
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search reports...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _statusFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Status')),
                  DropdownMenuItem(value: 'lost', child: Text('Lost')),
                  DropdownMenuItem(value: 'found', child: Text('Found')),
                  DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                ],
                onChanged: (value) {
                  setState(() {
                    _statusFilter = value!;
                  });
                  _applyFilters();
                },
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _typeFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Types')),
                  DropdownMenuItem(value: 'ID Card', child: Text('ID Card')),
                  DropdownMenuItem(value: 'Student Card', child: Text('Student Card')),
                  DropdownMenuItem(value: 'Passport', child: Text('Passport')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _typeFilter = value!;
                  });
                  _applyFilters();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text('Total Reports: ${_filteredReports.length}', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_filteredReports.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No reports found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: [
                      const DataColumn(label: Text('Select')),
                      const DataColumn(label: Text('Name')),
                      const DataColumn(label: Text('Type')),
                      const DataColumn(label: Text('Status')),
                      const DataColumn(label: Text('Institution')),
                      const DataColumn(label: Text('Date')),
                      const DataColumn(label: Text('Actions')),
                    ],
                    rows: _filteredReports.map((report) {
                      final timestamp = report['timestamp'] as Timestamp?;
                      final date = timestamp?.toDate() ?? DateTime.now();
                      final isSelected = _selectedReports.contains(report['id']);

                      return DataRow(
                        selected: isSelected,
                        cells: [
                          DataCell(
                            Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedReports.add(report['id']);
                                  } else {
                                    _selectedReports.remove(report['id']);
                                  }
                                });
                              },
                            ),
                          ),
                          DataCell(Text(report['name'] ?? 'Unknown')),
                          DataCell(Text(report['docType'] ?? 'Unknown')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(report['status']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                report['status']?.toString().toUpperCase() ?? 'UNKNOWN',
                                style: TextStyle(
                                  color: _getStatusColor(report['status']),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(report['institution'] ?? 'Unknown')),
                          DataCell(Text('${date.day}/${date.month}/${date.year}')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _showReportDetails(report),
                                  icon: const Icon(Icons.info, size: 16),
                                  tooltip: 'View Details',
                                ),
                                if (report['status'] != 'resolved')
                                  IconButton(
                                    onPressed: () => _markAsResolved(report['id']),
                                    icon: const Icon(Icons.check, size: 16, color: Colors.green),
                                    tooltip: 'Mark Resolved',
                                  ),
                                if (report['userId'] != null)
                                  IconButton(
                                    onPressed: () => _contactUser(report['userId']),
                                    icon: const Icon(Icons.email, size: 16, color: Colors.blue),
                                    tooltip: 'Contact User',
                                  ),
                                IconButton(
                                  onPressed: () => _deleteReport(report['id']),
                                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                  tooltip: 'Delete Report',
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'lost':
        return Colors.red[700]!;
      case 'found':
        return Colors.green[700]!;
      case 'resolved':
        return Colors.blue[700]!;
      default:
        return Colors.grey[700]!;
    }
  }
}

// Enhanced Analytics Screen
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  Map<String, dynamic> _analytics = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final reportsSnapshot = await _firestore.collection('reports').get();

      final users = usersSnapshot.docs;
      final reports = reportsSnapshot.docs;

      // Calculate analytics
      final totalUsers = users.length;
      final totalReports = reports.length;
      final resolvedReports = reports.where((doc) => doc.data()['status'] == 'resolved').length;
      final lostReports = reports.where((doc) => doc.data()['status'] == 'lost').length;
      final foundReports = reports.where((doc) => doc.data()['status'] == 'found').length;

      // Calculate success rate
      final successRate = totalReports > 0 ? (resolvedReports / totalReports * 100).roundToDouble() : 0.0;

      // Calculate monthly trends
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month);
      final lastMonth = DateTime(now.year, now.month - 1);

      final thisMonthReports = reports.where((doc) {
        final timestamp = doc.data()['timestamp'] as Timestamp?;
        if (timestamp == null) return false;
        final reportDate = timestamp.toDate();
        return reportDate.isAfter(thisMonth);
      }).length;

      final lastMonthReports = reports.where((doc) {
        final timestamp = doc.data()['timestamp'] as Timestamp?;
        if (timestamp == null) return false;
        final reportDate = timestamp.toDate();
        return reportDate.isAfter(lastMonth) && reportDate.isBefore(thisMonth);
      }).length;

      // Calculate document type distribution
      final docTypeCounts = <String, int>{};
      for (final report in reports) {
        final docType = report.data()['docType'] ?? 'Unknown';
        docTypeCounts[docType] = (docTypeCounts[docType] ?? 0) + 1;
      }

      setState(() {
        _analytics = {
          'totalUsers': totalUsers,
          'totalReports': totalReports,
          'resolvedReports': resolvedReports,
          'lostReports': lostReports,
          'foundReports': foundReports,
          'successRate': successRate,
          'thisMonthReports': thisMonthReports,
          'lastMonthReports': lastMonthReports,
          'docTypeCounts': docTypeCounts,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Analytics Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _loadAnalytics,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Analytics',
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Key Metrics Cards
                    Row(
                      children: [
                        Expanded(child: _buildMetricCard(
                          'Total Users',
                          _analytics['totalUsers']?.toString() ?? '0',
                          Icons.people,
                          Colors.blue,
                        )),
                        const SizedBox(width: 16),
                        Expanded(child: _buildMetricCard(
                          'Total Reports',
                          _analytics['totalReports']?.toString() ?? '0',
                          Icons.assignment,
                          Colors.orange,
                        )),
                        const SizedBox(width: 16),
                        Expanded(child: _buildMetricCard(
                          'Success Rate',
                          '${_analytics['successRate']?.toStringAsFixed(1) ?? '0'}%',
                          Icons.trending_up,
                          Colors.green,
                        )),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Report Status Distribution
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Report Status Distribution',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildStatusBar('Lost', _analytics['lostReports'] ?? 0, Colors.red),
                                  const SizedBox(height: 8),
                                  _buildStatusBar('Found', _analytics['foundReports'] ?? 0, Colors.green),
                                  const SizedBox(height: 8),
                                  _buildStatusBar('Resolved', _analytics['resolvedReports'] ?? 0, Colors.blue),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Monthly Trends',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTrendBar('This Month', _analytics['thisMonthReports'] ?? 0),
                                  const SizedBox(height: 8),
                                  _buildTrendBar('Last Month', _analytics['lastMonthReports'] ?? 0),
                                  const SizedBox(height: 16),
                                  Text(
                                    _analytics['thisMonthReports'] > _analytics['lastMonthReports']
                                        ? '📈 Reports increased this month'
                                        : '📉 Reports decreased this month',
                                    style: TextStyle(
                                      color: _analytics['thisMonthReports'] > _analytics['lastMonthReports']
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Document Type Distribution
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Document Type Distribution',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            if (_analytics['docTypeCounts'] != null)
                              ...(_analytics['docTypeCounts'] as Map<String, int>).entries.map((entry) {
                                final percentage = _analytics['totalReports'] > 0
                                    ? (entry.value / _analytics['totalReports'] * 100).roundToDouble()
                                    : 0.0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(entry.key),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: LinearProgressIndicator(
                                          value: percentage / 100,
                                          backgroundColor: Colors.grey[300],
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            _getDocTypeColor(entry.key),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('${entry.value} (${percentage.toStringAsFixed(1)}%)'),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Success Rate Chart
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Success Rate Over Time',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${_analytics['successRate']?.toStringAsFixed(1) ?? '0'}%',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: _getSuccessRateColor(_analytics['successRate'] ?? 0),
                                      ),
                                    ),
                                    const Text(
                                      'Overall Success Rate',
                                      style: TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(String status, int count, Color color) {
    final total = _analytics['totalReports'] ?? 1;
    final percentage = (count / total * 100).roundToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(status),
            Text('$count (${percentage.toStringAsFixed(1)}%)'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: count / total,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildTrendBar(String period, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(period),
        Text('$count reports'),
      ],
    );
  }

  Color _getDocTypeColor(String docType) {
    switch (docType.toLowerCase()) {
      case 'id card':
        return Colors.blue;
      case 'student card':
        return Colors.green;
      case 'passport':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getSuccessRateColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.orange;
    return Colors.red;
  }
}

// Enhanced Settings Screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoBackup = true;
  String _backupFrequency = 'daily';
  String _language = 'English';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // In a real app, load settings from Firebase or local storage
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate saving settings
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully'), backgroundColor: Colors.green),
    );
  }

  Future<void> _createBackup() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate backup creation
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup created successfully'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _createBackup,
                    icon: const Icon(Icons.backup),
                    label: const Text('Create Backup'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveSettings,
                    icon: _isLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: const Text('Save Settings'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Notifications Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Notifications',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: const Text('Email Notifications'),
                              subtitle: const Text('Receive notifications via email'),
                              value: true,
                              onChanged: (value) {
                                // Simple toggle without provider
                              },
                            ),
                            SwitchListTile(
                              title: const Text('Push Notifications'),
                              subtitle: const Text('Receive push notifications'),
                              value: true,
                              onChanged: (value) {
                                // Simple toggle without provider
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // System Configuration
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'System Configuration',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              title: const Text('Language'),
                              subtitle: Text(_language),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Select Language'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          title: const Text('English'),
                                          onTap: () {
                                            setState(() {
                                              _language = 'English';
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('French'),
                                          onTap: () {
                                            setState(() {
                                              _language = 'French';
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Kinyarwanda'),
                                          onTap: () {
                                            setState(() {
                                              _language = 'Kinyarwanda';
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Backup & Restore
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Backup & Restore',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: const Text('Auto Backup'),
                              subtitle: const Text('Automatically backup data'),
                              value: _autoBackup,
                              onChanged: (value) {
                                setState(() {
                                  _autoBackup = value;
                                });
                              },
                            ),
                            ListTile(
                              title: const Text('Backup Frequency'),
                              subtitle: Text(_backupFrequency),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Backup Frequency'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          title: const Text('Daily'),
                                          onTap: () {
                                            setState(() {
                                              _backupFrequency = 'daily';
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Weekly'),
                                          onTap: () {
                                            setState(() {
                                              _backupFrequency = 'weekly';
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Monthly'),
                                          onTap: () {
                                            setState(() {
                                              _backupFrequency = 'monthly';
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // System Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'System Information',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow('App Version', '1.0.0'),
                            _buildInfoRow('Database', 'Firebase Firestore'),
                            _buildInfoRow('Last Backup', 'Today, 10:30 AM'),
                            _buildInfoRow('Total Storage', '2.5 GB'),
                            _buildInfoRow('Active Users', '1,234'),
                            _buildInfoRow('Total Reports', '5,678'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Danger Zone
                    Card(
                      color: Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Danger Zone',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[700]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Clear All Data'),
                                    content: const Text('This will permanently delete all users and reports. This action cannot be undone.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Data cleared successfully'), backgroundColor: Colors.red),
                                          );
                                        },
                                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                                        child: const Text('Clear All'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.delete_forever),
                              label: const Text('Clear All Data'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// Audit Logs Screen
class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _auditLogs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _actionFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadAuditLogs();
  }

  Future<void> _loadAuditLogs() async {
    try {
      // Load real audit logs from Firestore
      final snapshot = await _firestore
          .collection('audit_logs')
          .orderBy('timestamp', descending: true)
          .limit(100) // Limit to last 100 logs for performance
          .get();

      final logs = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _auditLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      // If no audit_logs collection exists yet, show empty state
      setState(() {
        _auditLogs = [];
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredLogs {
    return _auditLogs.where((log) {
      final matchesSearch = log['description']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
                           log['adminName']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true;

      final matchesAction = _actionFilter == 'all' || log['action'] == _actionFilter;

      return matchesSearch && matchesAction;
    }).toList();
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'delete_user':
      case 'delete_report':
        return Colors.red;
      case 'change_role':
        return Colors.orange;
      case 'mark_resolved':
        return Colors.green;
      case 'export_data':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'delete_user':
      case 'delete_report':
        return Icons.delete;
      case 'change_role':
        return Icons.swap_horiz;
      case 'mark_resolved':
        return Icons.check_circle;
      case 'export_data':
        return Icons.download;
      default:
        return Icons.info;
    }
  }

  String _getActionLabel(String action) {
    switch (action) {
      case 'delete_user':
        return 'Delete User';
      case 'delete_report':
        return 'Delete Report';
      case 'change_role':
        return 'Change Role';
      case 'mark_resolved':
        return 'Mark Resolved';
      case 'export_data':
        return 'Export Data';
      default:
        return action.replaceAll('_', ' ').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Audit Logs',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _loadAuditLogs,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Logs',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search and filters
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search logs...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _actionFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Actions')),
                  DropdownMenuItem(value: 'delete_user', child: Text('Delete User')),
                  DropdownMenuItem(value: 'delete_report', child: Text('Delete Report')),
                  DropdownMenuItem(value: 'change_role', child: Text('Change Role')),
                  DropdownMenuItem(value: 'mark_resolved', child: Text('Mark Resolved')),
                  DropdownMenuItem(value: 'export_data', child: Text('Export Data')),
                ],
                onChanged: (value) {
                  setState(() {
                    _actionFilter = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text('Total Logs: ${_filteredLogs.length}', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_filteredLogs.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No audit logs found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Card(
                child: ListView.builder(
                  itemCount: _filteredLogs.length,
                  itemBuilder: (context, index) {
                    final log = _filteredLogs[index];
                    final timestamp = log['timestamp'] as Timestamp;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getActionColor(log['action']).withOpacity(0.1),
                        child: Icon(
                          _getActionIcon(log['action']),
                          color: _getActionColor(log['action']),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        _getActionLabel(log['action']),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log['description'] ?? ''),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                log['adminName'] ?? 'Unknown Admin',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                _formatTimestamp(timestamp),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'details',
                            child: Row(
                              children: [
                                Icon(Icons.info),
                                SizedBox(width: 8),
                                Text('View Details'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'export',
                            child: Row(
                              children: [
                                Icon(Icons.download),
                                SizedBox(width: 8),
                                Text('Export Log'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'details') {
                            _showLogDetails(log);
                          } else if (value == 'export') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Log exported successfully'), backgroundColor: Colors.green),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showLogDetails(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Audit Log Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Action: ${_getActionLabel(log['action'])}'),
            Text('Description: ${log['description']}'),
            Text('Admin: ${log['adminName']}'),
            Text('Admin ID: ${log['adminId']}'),
            if (log['targetId'] != null) Text('Target ID: ${log['targetId']}'),
            if (log['targetType'] != null) Text('Target Type: ${log['targetType']}'),
            Text('Timestamp: ${_formatTimestamp(log['timestamp'])}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}