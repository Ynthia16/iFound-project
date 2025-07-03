// This handles all the database operations for my iFound app
// I use Firebase Firestore to store reports, users, and feedback
// The service includes caching to make the app faster and more reliable
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Cache for reports to reduce Firebase calls
  static final Map<String, List<Map<String, dynamic>>> _reportsCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheValidity = Duration(minutes: 5);

  // Initialize Firestore with better settings
  static void initialize() {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      sslEnabled: true,
    );
  }

  // Check for matches when a new report is added
  Future<List<Map<String, dynamic>>> checkForMatches({
    required String name,
    required String docType,
    required String status,
    required String userId,
  }) async {
    // Get the opposite status (lost -> found, found -> lost)
    final oppositeStatus = status == 'lost' ? 'found' : 'lost';
    
    try {
      // Query for potential matches - more precise matching
      var query = _db.collection('reports')
          .where('status', isEqualTo: oppositeStatus)
          .where('name', isEqualTo: name.trim())
          .where('docType', isEqualTo: docType.trim());
      
      final snapshot = await query.get().timeout(const Duration(seconds: 15));
      
      // Convert to list of maps
      final matches = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
      
      return matches;
    } catch (e) {
      // Fallback: Get all reports and filter in memory for better compatibility
      try {
        final allReports = await _db.collection('reports').get().timeout(const Duration(seconds: 10));
        final allDocs = allReports.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList();
        
        // Filter in memory with exact matching
        final matches = allDocs.where((doc) {
          final docStatus = doc['status']?.toString().trim().toLowerCase();
          final docName = doc['name']?.toString().trim();
          final docDocType = doc['docType']?.toString().trim();
          
          final statusMatch = docStatus == oppositeStatus.toLowerCase();
          final nameMatch = docName == name.trim();
          final docTypeMatch = docDocType == docType.trim();
          
          // Only return exact matches for name and document type
          return statusMatch && nameMatch && docTypeMatch;
        }).toList();
        
        return matches;
      } catch (fallbackError) {
        return [];
      }
    }
  }

  // Add a lost/found report with retry logic and match checking
  Future<void> addReport({
    required String name,
    required String docType,
    required String institution,
    required String sector,
    required String status, // 'lost' or 'found'
    required String userId,
  }) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        await _db.collection('reports').add({
          'name': name,
          'docType': docType,
          'institution': institution,
          'sector': sector,
          'status': status,
          'userId': userId,
          'timestamp': FieldValue.serverTimestamp(),
        });
        
        // Check for matches after adding the report
        final matches = await checkForMatches(
          name: name,
          docType: docType,
          status: status,
          userId: userId,
        );
        
        if (matches.isNotEmpty) {
          await _storeMatchNotification(userId, matches);
        }

        // Clear cache when new report is added
        _clearCache();
        return; // Success, exit retry loop
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Failed to add report after $maxRetries attempts: $e');
        }
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
  }

  // Get reports with caching and timeout
  Stream<QuerySnapshot> getReports({String? status}) {
    try {
      var query = _db.collection('reports').orderBy('timestamp', descending: true);
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      return query.snapshots().timeout(const Duration(seconds: 8))
        .handleError((error) {
          return Stream.empty();
        });
    } catch (e) {
      return Stream.empty();
    }
  }

  // Get reports once (for initial load) with caching and retry
  Future<List<Map<String, dynamic>>> getReportsOnce({String? status}) async {
    try {
      final cacheKey = status ?? 'all';

      // Check cache first
      if (_reportsCache.containsKey(cacheKey) &&
          _cacheTimestamps.containsKey(cacheKey) &&
          DateTime.now().difference(_cacheTimestamps[cacheKey]!) < _cacheValidity) {
        return _reportsCache[cacheKey]!;
      }

      var query = _db.collection('reports').orderBy('timestamp', descending: true);
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      // Add retry logic for better reliability
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          final snapshot = await query.get().timeout(const Duration(seconds: 8));

          // Convert to list of maps and cache
          final reports = snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data(),
          }).toList();

          _reportsCache[cacheKey] = reports;
          _cacheTimestamps[cacheKey] = DateTime.now();

          return reports;
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) {
            return [];
          }
          // Wait before retrying
          await Future.delayed(Duration(seconds: retryCount * 2));
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // Clear cache
  void _clearCache() {
    _reportsCache.clear();
    _cacheTimestamps.clear();
  }

  // This is my search function - it lets users find reports by different criteria
  // I made it flexible so you can search by text, filter by status, type, sector, and dates
  // The search works both in Firebase queries and in memory for better results
  Future<List<Map<String, dynamic>>> searchReports({
    String? searchQuery,
    String? status,
    String? docType,
    String? sector,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _db.collection('reports').orderBy('timestamp', descending: true);

      // Apply filters
      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }
      if (docType != null && docType.isNotEmpty) {
        query = query.where('docType', isEqualTo: docType);
      }
      if (sector != null && sector.isNotEmpty) {
        query = query.where('sector', isEqualTo: sector);
      }

      final snapshot = await query.get().timeout(const Duration(seconds: 10));
      
      // Convert to list of maps
      List<Map<String, dynamic>> reports = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();

      // Apply additional filters in memory
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        reports = reports.where((report) {
          final name = report['name']?.toString().toLowerCase() ?? '';
          final docType = report['docType']?.toString().toLowerCase() ?? '';
          final institution = report['institution']?.toString().toLowerCase() ?? '';
          final sector = report['sector']?.toString().toLowerCase() ?? '';
          
          return name.contains(query) ||
                 docType.contains(query) ||
                 institution.contains(query) ||
                 sector.contains(query);
        }).toList();
      }

      // Apply date filters
      if (startDate != null || endDate != null) {
        reports = reports.where((report) {
          final timestamp = report['timestamp'];
          if (timestamp == null) return false;
          
          DateTime reportDate;
          if (timestamp is Timestamp) {
            reportDate = timestamp.toDate();
          } else if (timestamp is int) {
            reportDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
          } else {
            return false;
          }
          
          if (startDate != null && reportDate.isBefore(startDate)) {
            return false;
          }
          if (endDate != null && reportDate.isAfter(endDate)) {
            return false;
          }
          
          return true;
        }).toList();
      }

      return reports;
    } catch (e) {
      print('Error searching reports: $e');
      return [];
    }
  }

  // Store match notification for UI display
  Future<void> _storeMatchNotification(String userId, List<Map<String, dynamic>> matches) async {
    try {
      await _db.collection('users').doc(userId).update({
        'matches': matches,
        'lastMatchCheck': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle error silently
    }
  }

  // Get user's matches
  Future<List<Map<String, dynamic>>> getUserMatches(String userId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      final matches = userDoc.data()?['matches'] as List<dynamic>?;
      
      if (matches != null) {
        return matches.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  // Clear user's matches
  Future<void> clearUserMatches(String userId) async {
    try {
      await _db.collection('users').doc(userId).update({
        'matches': [],
      });
    } catch (e) {
      // Handle error silently
    }
  }

  // User profile methods
  Future<DocumentSnapshot?> getUserProfile(String userId) async {
    try {
      return await _db.collection('users').doc(userId).get();
    } catch (e) {
      return null;
    }
  }

  Future<void> setUserProfile({
    required String userId,
    required String name,
    required String email,
    String? photoUrl,
    String? theme,
    String? avatar,
  }) async {
    try {
      await _db.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'theme': theme,
        'avatar': avatar,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Handle error silently
    }
  }

  // Feedback methods
  Future<void> addFeedback({
    required String userId,
    required String feedback,
    int? rating,
    String? userName,
  }) async {
    try {
      await _db.collection('feedback').add({
        'userId': userId,
        'feedback': feedback,
        'rating': rating,
        'userName': userName,
        'likes': [],
        'replies': [],
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add feedback: $e');
    }
  }

  Future<void> toggleFeedbackLike({
    required String feedbackId,
    required String userId,
  }) async {
    try {
      final feedbackDoc = await _db.collection('feedback').doc(feedbackId).get();
      if (!feedbackDoc.exists) return;

      final data = feedbackDoc.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      await _db.collection('feedback').doc(feedbackId).update({
        'likes': likes,
      });
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  Future<void> addFeedbackReply({
    required String feedbackId,
    required String userId,
    required String reply,
    String? userName,
  }) async {
    try {
      final replyData = {
        'userId': userId,
        'userName': userName ?? 'Anonymous',
        'reply': reply,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _db.collection('feedback').doc(feedbackId).update({
        'replies': FieldValue.arrayUnion([replyData]),
      });
    } catch (e) {
      throw Exception('Failed to add reply: $e');
    }
  }

  Stream<QuerySnapshot> getFeedback() {
    try {
      return _db
          .collection('feedback')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .timeout(const Duration(seconds: 15))
          .handleError((error) {
            return Stream.empty();
          });
    } catch (e) {
      return Stream.empty();
    }
  }
} 