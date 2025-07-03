// This handles all the authentication for my iFound app
// I use Firebase Auth for secure login and registration
// Users can sign up with email/password and I handle all the security stuff
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update user profile in Firestore
      if (credential.user != null) {
        await _updateUserProfile(credential.user!);
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign up with email and password
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await _updateUserProfile(credential.user!);
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Enhanced Google Sign In with account selection
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Check if user is already signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Show account picker and sign in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
    if (googleUser == null) {
        // User cancelled the sign-in
        return null;
    }

      // Get auth details from request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Update user profile in Firestore
      if (userCredential.user != null) {
        await _updateUserProfile(userCredential.user!);
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('Google sign-in error: $e');
      }
      throw 'Failed to sign in with Google. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Alias for resetPassword for compatibility
  Future<void> sendPasswordResetEmail(String email) async {
    return resetPassword(email);
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update user profile in Firestore
  Future<void> _updateUserProfile(User user) async {
    try {
      await FirestoreService().setUserProfile(
        userId: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        photoUrl: user.photoURL,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update user profile: $e');
      }
      // Don't throw error as this is not critical for authentication
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'popup-closed-by-user':
        return 'Sign-in was cancelled.';
      case 'popup-blocked':
        return 'Pop-up was blocked. Please allow pop-ups and try again.';
      case 'cancelled-popup-request':
        return 'Sign-in was cancelled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but different sign-in credentials.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Get user display name
  String? get userDisplayName => _auth.currentUser?.displayName;

  // Get user email
  String? get userEmail => _auth.currentUser?.email;

  // Get user photo URL
  String? get userPhotoURL => _auth.currentUser?.photoURL;

  // Get user ID
  String? get userId => _auth.currentUser?.uid;
} 