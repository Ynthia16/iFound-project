import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getting comprehensive dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Getting total users
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;

      // Getting active reports
      final activeReportsSnapshot = await _firestore
          .collection('reports')
          .where('status', isEqualTo: 'active')
          .get();
      final activeReports = activeReportsSnapshot.docs.length;

      // Getting matches made
      final matchesSnapshot = await _firestore
          .collection('reports')
          .where('status', isEqualTo: 'matched')
          .get();
      final matchesMade = matchesSnapshot.docs.length;

      // Getting today's reports
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final todayReportsSnapshot = await _firestore
          .collection('reports')
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .get();
      final todayReports = todayReportsSnapshot.docs.length;

      // Getting pending reports
      final pendingReportsSnapshot = await _firestore
          .collection('reports')
          .where('status', isEqualTo: 'pending')
          .get();
      final pendingReports = pendingReportsSnapshot.docs.length;

      // Getting reports by type
      final lostReportsSnapshot = await _firestore
          .collection('reports')
          .where('type', isEqualTo: 'lost')
          .get();
      final lostReports = lostReportsSnapshot.docs.length;

      final foundReportsSnapshot = await _firestore
          .collection('reports')
          .where('type', isEqualTo: 'found')
          .get();
      final foundReports = foundReportsSnapshot.docs.length;

      // Calculating success rate
      final totalReports = lostReports + foundReports;
      final successRate = totalReports > 0 ? (matchesMade / totalReports * 100).round() : 0;

      return {
        'totalUsers': totalUsers,
        'activeReports': activeReports,
        'matchesMade': matchesMade,
        'todayReports': todayReports,
        'pendingReports': pendingReports,
        'lostReports': lostReports,
        'foundReports': foundReports,
        'totalReports': totalReports,
        'successRate': successRate,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      // Return default values if there's an error
      return {
        'totalUsers': 0,
        'activeReports': 0,
        'matchesMade': 0,
        'todayReports': 0,
        'pendingReports': 0,
        'lostReports': 0,
        'foundReports': 0,
        'totalReports': 0,
        'successRate': 0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }

  // Getting detailed analytics data
  Future<Map<String, dynamic>> getAnalyticsData() async {
    try {
      // Getting reports by type
      final lostReportsSnapshot = await _firestore
          .collection('reports')
          .where('type', isEqualTo: 'lost')
          .get();
      final foundReportsSnapshot = await _firestore
          .collection('reports')
          .where('type', isEqualTo: 'found')
          .get();

      // Get reports by status
      final pendingReportsSnapshot = await _firestore
          .collection('reports')
          .where('status', isEqualTo: 'pending')
          .get();
      final activeReportsSnapshot = await _firestore
          .collection('reports')
          .where('status', isEqualTo: 'active')
          .get();
      final matchedReportsSnapshot = await _firestore
          .collection('reports')
          .where('status', isEqualTo: 'matched')
          .get();
      final closedReportsSnapshot = await _firestore
          .collection('reports')
          .where('status', isEqualTo: 'closed')
          .get();

      // Get reports by category/sector
      final reportsSnapshot = await _firestore.collection('reports').get();
      final categoryStats = <String, int>{};
      for (var doc in reportsSnapshot.docs) {
        final data = doc.data();
        final category = data['sector'] ?? data['category'] ?? 'Unknown';
        categoryStats[category] = (categoryStats[category] ?? 0) + 1;
      }

      // Get weekly trends (last 7 days)
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final weeklyReportsSnapshot = await _firestore
          .collection('reports')
          .where('createdAt', isGreaterThanOrEqualTo: weekAgo)
          .orderBy('createdAt')
          .get();

      final weeklyData = <String, int>{};
      for (var doc in weeklyReportsSnapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final day = '${createdAt.month}/${createdAt.day}';
        weeklyData[day] = (weeklyData[day] ?? 0) + 1;
      }

      return {
        'lostReports': lostReportsSnapshot.docs.length,
        'foundReports': foundReportsSnapshot.docs.length,
        'pendingReports': pendingReportsSnapshot.docs.length,
        'activeReports': activeReportsSnapshot.docs.length,
        'matchedReports': matchedReportsSnapshot.docs.length,
        'closedReports': closedReportsSnapshot.docs.length,
        'categoryStats': categoryStats,
        'weeklyTrends': weeklyData,
        'totalReports': reportsSnapshot.docs.length,
      };
    } catch (e) {
      return {
        'lostReports': 0,
        'foundReports': 0,
        'pendingReports': 0,
        'activeReports': 0,
        'matchedReports': 0,
        'closedReports': 0,
        'categoryStats': {},
        'weeklyTrends': {},
        'totalReports': 0,
      };
    }
  }

  // Get all users with detailed information
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        // Calculate user stats
        final createdAt = data['createdAt'] as Timestamp?;
        data['daysSinceJoined'] = createdAt != null
            ? DateTime.now().difference(createdAt.toDate()).inDays
            : 0;

        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get all reports with detailed information
  Future<List<Map<String, dynamic>>> getAllReports() async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        // Format dates
        final createdAt = data['createdAt'] as Timestamp?;
        final updatedAt = data['updatedAt'] as Timestamp?;

        data['createdAtFormatted'] = createdAt?.toDate().toString();
        data['updatedAtFormatted'] = updatedAt?.toDate().toString();

        // Calculate report age
        data['daysOld'] = createdAt != null
            ? DateTime.now().difference(createdAt.toDate()).inDays
            : 0;

        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get recent activity
  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    try {
      final now = DateTime.now();
      final dayAgo = now.subtract(const Duration(days: 1));

      // Get recent reports
      final recentReportsSnapshot = await _firestore
          .collection('reports')
          .where('createdAt', isGreaterThanOrEqualTo: dayAgo)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      final activities = <Map<String, dynamic>>[];

      for (var doc in recentReportsSnapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final timeAgo = _getTimeAgo(createdAt);

        activities.add({
          'type': 'report',
          'action': '${data['type']} item reported',
          'time': timeAgo,
          'userId': data['userId'],
          'reportId': doc.id,
          'timestamp': createdAt,
        });
      }

      // Get recent user registrations
      final recentUsersSnapshot = await _firestore
          .collection('users')
          .where('createdAt', isGreaterThanOrEqualTo: dayAgo)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      for (var doc in recentUsersSnapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final timeAgo = _getTimeAgo(createdAt);

        activities.add({
          'type': 'user',
          'action': 'New user registered',
          'time': timeAgo,
          'userId': doc.id,
          'email': data['email'],
          'timestamp': createdAt,
        });
      }

      // Sort by timestamp
      activities.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

      return activities.take(15).toList();
    } catch (e) {
      return [];
    }
  }

  // Helper method to get time ago
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  // Update user role
  Future<bool> updateUserRole(String userId, String role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update report status
  Future<bool> updateReportStatus(String reportId, String status) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete report
  Future<bool> deleteReport(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Add new user document
  Future<bool> addUser({
    required String userId,
    required String name,
    required String email,
    String? photoUrl,
    String? theme,
    String? avatar,
    String? role,
    String? fcmToken,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'theme': theme ?? 'light',
        'avatar': avatar,
        'role': role ?? 'user',
        'fcmToken': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'matches': [],
        'lastMatchCheck': null,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user document
  Future<bool> updateUser({
    required String userId,
    String? name,
    String? email,
    String? photoUrl,
    String? theme,
    String? avatar,
    String? role,
    String? fcmToken,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      if (theme != null) updateData['theme'] = theme;
      if (avatar != null) updateData['avatar'] = avatar;
      if (role != null) updateData['role'] = role;
      if (fcmToken != null) updateData['fcmToken'] = fcmToken;

      await _firestore.collection('users').doc(userId).update(updateData);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Create the first admin user (for initial setup)
  Future<bool> createFirstAdmin({
    required String userId,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    try {
      // Check if any admin already exists
      final adminCheck = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (adminCheck.docs.isNotEmpty) {
        throw Exception('Admin already exists. Use regular addUser method.');
      }

      // Create the first admin
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'theme': 'light',
        'avatar': null,
        'role': 'admin', // This makes them an admin
        'fcmToken': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'matches': [],
        'lastMatchCheck': null,
        'isAdmin': true, // Additional admin flag
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Promote user to admin
  Future<bool> promoteToAdmin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': 'admin',
        'isAdmin': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Demote admin to regular user
  Future<bool> demoteFromAdmin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': 'user',
        'isAdmin': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get all admins
  Future<List<Map<String, dynamic>>> getAdmins() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Check if user is admin
  Future<bool> isUserAdmin(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['role'] == 'admin' || userData['isAdmin'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}