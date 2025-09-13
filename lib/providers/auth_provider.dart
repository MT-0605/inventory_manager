import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';

/// Authentication provider for managing user state
class AuthProvider with ChangeNotifier {
  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  /// Initialize auth state listener
  void init() {
    FirebaseService.auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  /// Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      _setLoading(true);
      final doc = await FirebaseService.usersCollection.doc(uid).get();

      if (doc.exists) {
        _user = AppUser.fromFirestore(doc);
      } else {
        // Create new user document if it doesn't exist
        final firebaseUser = FirebaseService.auth.currentUser!;
        _user = AppUser.fromFirebaseUser(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          displayName: firebaseUser.displayName,
          phoneNumber: firebaseUser.phoneNumber,
        );
        await _saveUserData();
      }
      _clearError();
    } catch (e) {
      _setError('Failed to load user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Save user data to Firestore
  Future<void> _saveUserData() async {
    if (_user != null) {
      await FirebaseService.usersCollection
          .doc(_user!.id)
          .set(_user!.toFirestore());
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.signInWithEmailAndPassword(email, password);
      return true;
    } catch (e) {
      _setError('Sign in failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Create account with email and password
  Future<bool> createAccountWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final userCredential =
          await FirebaseService.createUserWithEmailAndPassword(email, password);

      // Create user document
      _user = AppUser.fromFirebaseUser(
        id: userCredential.user!.uid,
        email: email,
        displayName: displayName,
      );

      await _saveUserData();
      return true;
    } catch (e) {
      _setError('Account creation failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? shopName,
    String? address,
  }) async {
    if (_user == null) return false;

    try {
      _setLoading(true);
      _clearError();

      _user = _user!.copyWith(
        displayName: displayName,
        phoneNumber: phoneNumber,
        shopName: shopName,
        address: address,
      );

      await _saveUserData();
      return true;
    } catch (e) {
      _setError('Profile update failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await FirebaseService.signOut();
      _user = null;
      _clearError();
    } catch (e) {
      _setError('Sign out failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
