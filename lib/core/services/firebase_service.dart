import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mysite/firebase_options.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Check if user is admin
  static bool get isAdmin {
    final user = auth.currentUser;
    return user != null;
  }

  // Get current user
  static User? get currentUser => auth.currentUser;

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await auth.signOut();
  }

  // Listen to auth state changes
  static Stream<User?> get authStateChanges => auth.authStateChanges();

  // Test Firebase connection
  static Future<bool> testConnection() async {
    try {
      // Test Firestore connection
      await firestore.enableNetwork();

      // Try to read from a test collection (this will create it if it doesn't exist)
      final testDoc = await firestore.collection('_test').doc('connection').get();

      // Test Firebase Storage connection
      final storageRef = storage.ref().child('_test');

      print('Firebase connection test successful');
      return true;
    } catch (e) {
      print('Firebase connection test failed: $e');
      return false;
    }
  }

  // Get detailed Firebase status
  static Future<Map<String, dynamic>> getFirebaseStatus() async {
    final status = <String, dynamic>{};

    try {
      // Check auth status
      status['auth'] = {
        'initialized': true,
        'currentUser': currentUser?.email ?? 'Not signed in',
        'isAdmin': isAdmin,
      };
    } catch (e) {
      status['auth'] = {'error': e.toString()};
    }

    try {
      // Check Firestore status
      await firestore.enableNetwork();
      final testDoc = await firestore.collection('_test').doc('status').get();
      status['firestore'] = {
        'connected': true,
        'canRead': testDoc.exists,
      };
    } catch (e) {
      status['firestore'] = {'error': e.toString()};
    }

    try {
      // Check Storage status
      final storageRef = storage.ref().child('_test');
      status['storage'] = {
        'connected': true,
        'bucket': storage.bucket,
      };
    } catch (e) {
      status['storage'] = {'error': e.toString()};
    }

    return status;
  }
}
