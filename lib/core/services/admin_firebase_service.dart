import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mysite/core/services/public_firebase_service.dart';
import 'dart:typed_data';

/// Admin-specific Firebase service
/// Only initializes when admin functionality is needed
class AdminFirebaseService {
  static FirebaseAuth? _auth;
  static FirebaseStorage? _storage;
  static bool _adminInitialized = false;

  static FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception('AdminFirebaseService not initialized. Call initializeAdmin() first.');
    }
    return _auth!;
  }

  static FirebaseStorage get storage {
    if (_storage == null) {
      throw Exception('AdminFirebaseService not initialized. Call initializeAdmin() first.');
    }
    return _storage!;
  }

  static bool get isAdminInitialized => _adminInitialized;

  /// Initialize admin services (only when needed)
  static Future<void> initializeAdmin() async {
    if (_adminInitialized) return;

    try {
      // Ensure public Firebase is initialized first
      if (!PublicFirebaseService.isInitialized) {
        await PublicFirebaseService.initialize();
      }

      // Initialize admin-specific services
      _auth = FirebaseAuth.instance;
      _storage = FirebaseStorage.instance;

      _adminInitialized = true;
      print('AdminFirebaseService initialized successfully');
    } catch (e) {
      print('AdminFirebaseService initialization failed: $e');
      rethrow;
    }
  }

  /// Check if user is admin
  static bool get isAdmin {
    if (!_adminInitialized) return false;
    final user = _auth?.currentUser;
    return user != null;
  }

  /// Get current user
  static User? get currentUser => _auth?.currentUser;

  /// Sign in with email and password
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!_adminInitialized) {
      await initializeAdmin();
    }

    try {
      return await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    if (_adminInitialized && _auth != null) {
      await _auth!.signOut();
    }
  }

  /// Listen to auth state changes
  static Stream<User?> get authStateChanges {
    if (!_adminInitialized) {
      return Stream.empty();
    }
    return _auth!.authStateChanges();
  }

  /// Upload file to Firebase Storage
  static Future<String> uploadFile({
    required String path,
    required List<int> bytes,
    required String fileName,
  }) async {
    if (!_adminInitialized) {
      await initializeAdmin();
    }

    try {
      final ref = _storage!.ref().child(path).child(fileName);
      final uploadTask = ref.putData(Uint8List.fromList(bytes));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('File upload failed: ${e.toString()}');
    }
  }

  /// Delete file from Firebase Storage
  static Future<void> deleteFile(String url) async {
    if (!_adminInitialized) return;

    try {
      final ref = _storage!.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('File deletion failed: $e');
      // Don't throw error for file deletion failures
    }
  }

  /// Test admin connection
  static Future<bool> testAdminConnection() async {
    try {
      if (!_adminInitialized) {
        await initializeAdmin();
      }

      // Test auth
      final user = _auth!.currentUser;
      
      // Test storage
      await _storage!.ref().child('_test').listAll();

      return true;
    } catch (e) {
      print('Admin connection test failed: $e');
      return false;
    }
  }

  /// Dispose admin resources
  static void disposeAdmin() {
    _auth = null;
    _storage = null;
    _adminInitialized = false;
  }
}
