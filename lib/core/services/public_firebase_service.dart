import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mysite/firebase_options.dart';
import 'package:mysite/core/models/project_model.dart';
import 'package:mysite/core/models/service_model.dart';
import 'package:mysite/core/models/content_model.dart';
import 'package:mysite/core/services/content_service.dart';

/// Lightweight Firebase service for public portfolio
/// Only initializes what's needed for public viewing
class PublicFirebaseService {
  static FirebaseFirestore? _firestore;
  static bool _initialized = false;

  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('PublicFirebaseService not initialized. Call initialize() first.');
    }
    return _firestore!;
  }

  static bool get isInitialized => _initialized;

  /// Initialize Firebase for public portfolio (lightweight)
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      _firestore = FirebaseFirestore.instance;
      
      // Configure Firestore for better performance
      await _configureFirestore();

      // Initialize default content if needed
      await ContentService.initializeDefaultContent();

      _initialized = true;
      print('PublicFirebaseService initialized successfully');
    } catch (e) {
      print('PublicFirebaseService initialization failed: $e');
      rethrow;
    }
  }

  /// Configure Firestore settings for optimal performance
  static Future<void> _configureFirestore() async {
    try {
      // Enable offline persistence for better performance
      await _firestore!.enableNetwork();
      
      // Set cache size (optional)
      // await _firestore!.settings = const Settings(
      //   cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      // );
    } catch (e) {
      print('Firestore configuration warning: $e');
      // Continue even if configuration fails
    }
  }

  /// Get all active projects for public viewing
  static Stream<List<ProjectModel>> getActiveProjects() {
    return firestore
        .collection('projects')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProjectModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Get all active services for public viewing
  static Stream<List<ServiceModel>> getActiveServices() {
    return firestore
        .collection('services')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ServiceModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Get all content for public viewing
  static Stream<Map<String, String>> getContent() {
    return firestore
        .collection('content')
        .snapshots()
        .map((snapshot) {
          final Map<String, String> content = {};
          for (final doc in snapshot.docs) {
            final contentModel = ContentModel.fromFirestore(doc);
            content[contentModel.key] = contentModel.value;
          }
          return content;
        });
  }

  /// Get specific content by key
  static Future<String?> getContentByKey(String key) async {
    try {
      final doc = await firestore.collection('content').doc(key).get();
      if (doc.exists) {
        final contentModel = ContentModel.fromFirestore(doc);
        return contentModel.value;
      }
      return null;
    } catch (e) {
      print('Error getting content for key $key: $e');
      return null;
    }
  }

  /// Test connection (lightweight)
  static Future<bool> testConnection() async {
    try {
      await firestore.collection('_health').doc('check').get();
      return true;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  /// Dispose resources
  static void dispose() {
    _firestore = null;
    _initialized = false;
  }
}
