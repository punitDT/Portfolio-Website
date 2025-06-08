import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mysite/core/services/admin_firebase_service.dart';
import 'dart:async';
import 'package:mysite/core/services/admin_auth_service.dart';
import 'package:mysite/core/services/local_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authStateSubscription;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user != null; // Only Firebase authenticated users are admin

  AuthProvider() {
    // Don't initialize admin services automatically for better performance
    print('Auth provider initialized (admin services will load on demand)');
  }

  Future<void> _initializeAdminServices() async {
    try {
      if (!AdminFirebaseService.isAdminInitialized) {
        await AdminFirebaseService.initializeAdmin();

        // Set up auth state listener
        _authStateSubscription = AdminFirebaseService.authStateChanges.listen((User? user) {
          _user = user;
          notifyListeners();
        });

        print('Admin Firebase services initialized successfully');
      }
    } catch (e) {
      print('Admin Firebase initialization failed: $e');
      rethrow;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      // Initialize admin services only when login is attempted
      await _initializeAdminServices();

      // Use Firebase authentication
      final userCredential = await AdminFirebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential != null) {
        _user = userCredential.user;
        _setLoading(false);
        return true;
      }

      _setError('Authentication failed. Please check your credentials.');
      _setLoading(false);
      return false;
    } catch (e) {
      print('Authentication error: $e');
      _setError('Authentication failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);

      // Sign out from Firebase
      await AdminFirebaseService.signOut();

      _user = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
