import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  bool _isAdmin = false;
  bool _isLoading = false;
  String? _userName;

  User? get user => _user;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get userName => _userName;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    if (user != null) {
      _checkAdminStatus();
    } else {
      _isAdmin = false;
      _userName = null;
    }
    notifyListeners();
  }

  Future<void> _checkAdminStatus() async {
    if (_user == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _isAdmin = userData['isAdmin'] == true || userData['role'] == 'admin';
        _userName = userData['name'] ?? _user!.displayName ?? _user!.email;
        
        // Update last login
        await _firestore.collection('users').doc(_user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        // If user exists in Auth but not in Firestore, create the document
        await _firestore.collection('users').doc(_user!.uid).set({
          'name': _user!.displayName ?? _user!.email,
          'email': _user!.email,
          'role': 'admin',
          'isAdmin': true,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
        _isAdmin = true;
        _userName = _user!.displayName ?? _user!.email;
      }
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      _isAdmin = false;
    }
    
    notifyListeners();
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _checkAdminStatus();
      return _isAdmin;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Password reset error: $e');
      rethrow;
    }
  }
} 