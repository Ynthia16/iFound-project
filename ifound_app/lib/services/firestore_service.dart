// This handles all the database operations for my iFound app
// I use Firebase Firestore to store reports, users, and feedback
// The service includes caching to make the app faster and more reliable
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/foundation.dart'; // Added for kDebugMode

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

  // Enhanced matching algorithm with location and sector consideration
  Future<List<Map<String, dynamic>>> checkForMatches({
    required String name,
    required String docType,
    required String status,
    required String userId,
    String? institution,
    String? sector,
  }) async {
    // Get the opposite status (lost -> found, found -> lost)
    final oppositeStatus = status == 'lost' ? 'found' : 'lost';
    
    try {
      // First try exact matching for immediate results
      var exactQuery = _db.collection('reports')
          .where('status', isEqualTo: oppositeStatus)
          .where('name', isEqualTo: name.trim())
          .where('docType', isEqualTo: docType.trim());
      
      final exactSnapshot = await exactQuery.get().timeout(const Duration(seconds: 10));
      final exactMatches = exactSnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
        'matchScore': 100, // Perfect match
      }).toList();
      
      // If we have exact matches, return them immediately
      if (exactMatches.isNotEmpty) {
        return exactMatches;
      }
      
      // If no exact matches, try fuzzy matching
      final allReports = await _db.collection('reports').get().timeout(const Duration(seconds: 15));
      final allDocs = allReports.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
      
      // Filter and score potential matches
      final potentialMatches = <Map<String, dynamic>>[];
      
      for (final doc in allDocs) {
        final docStatus = doc['status']?.toString().trim().toLowerCase();
        final docName = doc['name']?.toString().trim();
        final docDocType = doc['docType']?.toString().trim();
        final docInstitution = doc['institution']?.toString().trim();
        final docSector = doc['sector']?.toString().trim();
        
        // Must have opposite status
        if (docStatus != oppositeStatus.toLowerCase()) continue;
        
        // Calculate similarity scores
        final nameSimilarity = _calculateNameSimilarity(name.trim(), docName ?? '');
        final docTypeSimilarity = _calculateDocTypeSimilarity(docType.trim(), docDocType ?? '');
        final locationSimilarity = _calculateLocationSimilarity(institution, docInstitution);
        final sectorSimilarity = _calculateSectorSimilarity(sector, docSector);
        
        // Enhanced scoring with location and sector
        // Name and document type are most important (70% weight)
        // Location and sector provide additional context (30% weight)
        if (nameSimilarity >= 0.7 && docTypeSimilarity >= 0.8) {
          final matchScore = (
            nameSimilarity * 0.4 + 
            docTypeSimilarity * 0.3 + 
            locationSimilarity * 0.2 + 
            sectorSimilarity * 0.1
          ) * 100;
          
          potentialMatches.add({
            ...doc,
            'matchScore': matchScore.round(),
            'nameSimilarity': nameSimilarity,
            'docTypeSimilarity': docTypeSimilarity,
            'locationSimilarity': locationSimilarity,
            'sectorSimilarity': sectorSimilarity,
          });
        }
      }
      
      // Sort by match score (highest first) and return top matches
      potentialMatches.sort((a, b) => (b['matchScore'] as int).compareTo(a['matchScore'] as int));
      return potentialMatches.take(5).toList(); // Return top 5 matches
      
    } catch (e) {
      // Fallback to exact matching if fuzzy matching fails
      try {
        final allReports = await _db.collection('reports').get().timeout(const Duration(seconds: 10));
        final allDocs = allReports.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList();
        
        final matches = allDocs.where((doc) {
          final docStatus = doc['status']?.toString().trim().toLowerCase();
          final docName = doc['name']?.toString().trim();
          final docDocType = doc['docType']?.toString().trim();
          
          final statusMatch = docStatus == oppositeStatus.toLowerCase();
          final nameMatch = docName == name.trim();
          final docTypeMatch = docDocType == docType.trim();
          
          return statusMatch && nameMatch && docTypeMatch;
        }).toList();
        
        return matches.map((match) => {
          ...match,
          'matchScore': 100,
        }).toList();
      } catch (fallbackError) {
        return [];
      }
    }
  }

  // Calculate name similarity using multiple algorithms
  double _calculateNameSimilarity(String name1, String name2) {
    if (name1.isEmpty || name2.isEmpty) return 0.0;
    
    // Normalize names for comparison
    final normalized1 = _normalizeName(name1);
    final normalized2 = _normalizeName(name2);
    
    // Exact match after normalization
    if (normalized1 == normalized2) return 1.0;
    
    // Check for partial matches (one name contains the other)
    if (normalized1.contains(normalized2) || normalized2.contains(normalized1)) {
      return 0.9;
    }
    
    // Calculate Levenshtein distance for similarity
    final distance = _levenshteinDistance(normalized1, normalized2);
    final maxLength = normalized1.length > normalized2.length ? normalized1.length : normalized2.length;
    
    if (maxLength == 0) return 0.0;
    
    final similarity = 1.0 - (distance / maxLength);
    
    // Boost similarity for common name variations
    if (_areNameVariations(normalized1, normalized2)) {
      return (similarity + 0.2).clamp(0.0, 1.0);
    }
    
    return similarity;
  }

  // Calculate document type similarity
  double _calculateDocTypeSimilarity(String type1, String type2) {
    if (type1.isEmpty || type2.isEmpty) return 0.0;
    
    final normalized1 = type1.toLowerCase().trim();
    final normalized2 = type2.toLowerCase().trim();
    
    // Exact match
    if (normalized1 == normalized2) return 1.0;
    
    // Check for common abbreviations and variations
    final variations = {
      'id': ['identity', 'identification', 'card'],
      'passport': ['passport', 'travel document'],
      'license': ['driving license', 'driver license', 'license'],
      'certificate': ['cert', 'certificate', 'diploma'],
      'phone': ['mobile', 'cellphone', 'smartphone'],
      'wallet': ['purse', 'wallet'],
      'keys': ['key', 'keys'],
    };
    
    // Check if both types are in the same variation group
    for (final group in variations.entries) {
      if (group.value.contains(normalized1) && group.value.contains(normalized2)) {
        return 0.95;
      }
    }
    
    // Calculate similarity using Levenshtein distance
    final distance = _levenshteinDistance(normalized1, normalized2);
    final maxLength = normalized1.length > normalized2.length ? normalized1.length : normalized2.length;
    
    if (maxLength == 0) return 0.0;
    
    return 1.0 - (distance / maxLength);
  }

  // Normalize name for better comparison
  String _normalizeName(String name) {
    return name.toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
  }

  // Check if names are common variations of each other
  bool _areNameVariations(String name1, String name2) {
    final variations = {
      'john': ['johnny', 'jon'],
      'michael': ['mike', 'mikey'],
      'william': ['will', 'bill', 'billy'],
      'robert': ['rob', 'bob', 'bobby'],
      'james': ['jim', 'jimmy'],
      'david': ['dave', 'davey'],
      'richard': ['rick', 'ricky', 'dick'],
      'thomas': ['tom', 'tommy'],
      'christopher': ['chris', 'topher'],
      'daniel': ['dan', 'danny'],
    };
    
    for (final group in variations.entries) {
      if (group.value.contains(name1) && group.value.contains(name2)) {
        return true;
      }
    }
    
    return false;
  }

  // Calculate Levenshtein distance between two strings
  int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;
    
    final matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );
    
    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }
    
    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    
    return matrix[s1.length][s2.length];
  }

  // Calculate location similarity
  double _calculateLocationSimilarity(String? location1, String? location2) {
    if (location1 == null || location2 == null || location1.isEmpty || location2.isEmpty) {
      return 0.5; // Neutral score if location info is missing
    }
    
    final normalized1 = location1.toLowerCase().trim();
    final normalized2 = location2.toLowerCase().trim();
    
    // Exact match
    if (normalized1 == normalized2) return 1.0;
    
    // Check for partial matches
    if (normalized1.contains(normalized2) || normalized2.contains(normalized1)) {
      return 0.8;
    }
    
    // Calculate similarity using Levenshtein distance
    final distance = _levenshteinDistance(normalized1, normalized2);
    final maxLength = normalized1.length > normalized2.length ? normalized1.length : normalized2.length;
    
    if (maxLength == 0) return 0.0;
    
    return 1.0 - (distance / maxLength);
  }

  // Calculate sector similarity
  double _calculateSectorSimilarity(String? sector1, String? sector2) {
    if (sector1 == null || sector2 == null || sector1.isEmpty || sector2.isEmpty) {
      return 0.5; // Neutral score if sector info is missing
    }
    
    final normalized1 = sector1.toLowerCase().trim();
    final normalized2 = sector2.toLowerCase().trim();
    
    // Exact match
    if (normalized1 == normalized2) return 1.0;
    
    // Check for common sector variations
    final sectorVariations = {
      'education': ['school', 'university', 'college', 'academic'],
      'healthcare': ['hospital', 'clinic', 'medical', 'health'],
      'government': ['gov', 'government', 'public', 'official'],
      'business': ['corporate', 'company', 'office', 'work'],
      'transportation': ['transport', 'travel', 'commute', 'transit'],
    };
    
    // Check if both sectors are in the same variation group
    for (final group in sectorVariations.entries) {
      if (group.value.contains(normalized1) && group.value.contains(normalized2)) {
        return 0.9;
      }
    }
    
    // Calculate similarity using Levenshtein distance
    final distance = _levenshteinDistance(normalized1, normalized2);
    final maxLength = normalized1.length > normalized2.length ? normalized1.length : normalized2.length;
    
    if (maxLength == 0) return 0.0;
    
    return 1.0 - (distance / maxLength);
  }

  // Add a lost/found report with retry logic and enhanced match checking
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
          'timestamp': DateTime.now().toIso8601String(), // Use client timestamp for faster response
        });
        
        // Check for matches after adding the report with enhanced parameters
        final matches = await checkForMatches(
          name: name,
          docType: docType,
          status: status,
          userId: userId,
          institution: institution,
          sector: sector,
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
          
          DateTime? reportDate;
          if (timestamp is Timestamp) {
            reportDate = timestamp.toDate();
          } else if (timestamp is int) {
            reportDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
          } else if (timestamp is String) {
            reportDate = DateTime.tryParse(timestamp);
          }
          
          // If we couldn't parse the timestamp, skip this report
          if (reportDate == null) return false;
          
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
      if (kDebugMode) {
        print('Error saving user profile: $e');
      }
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
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        await _db.collection('feedback').add({
          'userId': userId,
          'feedback': feedback,
        'rating': rating,
        'userName': userName,
        'likes': [],
        'replies': [],
          'timestamp': DateTime.now().toIso8601String(), // Use client timestamp for faster response
        }).timeout(const Duration(seconds: 5)); // Add timeout protection
        
        return; // Success, exit retry loop
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Failed to add feedback after $maxRetries attempts: $e');
        }
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: retryCount));
      }
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
        'timestamp': DateTime.now().toIso8601String(), // Use client timestamp for faster response
      };

      await _db.collection('feedback').doc(feedbackId).update({
        'replies': FieldValue.arrayUnion([replyData]),
      }).timeout(const Duration(seconds: 5)); // Add timeout protection
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

  // Mark report as resolved when match is found
  Future<void> markReportAsResolved(String reportId, {String? resolutionNote}) async {
    try {
      await _db.collection('reports').doc(reportId).update({
        'status': 'resolved',
        'isResolved': true,
        'resolvedAt': DateTime.now().toIso8601String(),
        'resolutionNote': resolutionNote ?? 'Match found and resolved',
      });
    } catch (e) {
      throw Exception('Failed to mark report as resolved: $e');
    }
  }

  // Mark report as claimed when user claims their item
  Future<void> markReportAsClaimed(String reportId, {String? claimNote}) async {
    try {
      await _db.collection('reports').doc(reportId).update({
        'status': 'claimed',
        'isResolved': true,
        'claimedAt': DateTime.now().toIso8601String(),
        'claimNote': claimNote ?? 'Item claimed by owner',
      });
    } catch (e) {
      throw Exception('Failed to mark report as claimed: $e');
    }
  }
} 