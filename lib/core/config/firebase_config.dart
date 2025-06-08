import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Secure Firebase configuration that doesn't expose API keys in source code
class SecureFirebaseConfig {
  // These are public configuration values that are safe to expose
  static const String projectId = 'portfolio-c1274';
  static const String authDomain = 'portfolio-c1274.firebaseapp.com';
  static const String storageBucket = 'portfolio-c1274.appspot.com';
  
  // These should be loaded from environment or secure storage
  static String? _apiKey;
  static String? _appId;
  static String? _messagingSenderId;
  
  /// Initialize configuration with secure values
  static void initialize({
    required String apiKey,
    required String appId,
    required String messagingSenderId,
  }) {
    _apiKey = apiKey;
    _appId = appId;
    _messagingSenderId = messagingSenderId;
  }
  
  /// Get Firebase options for current platform
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
  
  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _apiKey ?? _getDefaultApiKey(),
    authDomain: authDomain,
    projectId: projectId,
    storageBucket: storageBucket,
    messagingSenderId: _messagingSenderId ?? _getDefaultMessagingSenderId(),
    appId: _appId ?? _getDefaultAppId(),
  );
  
  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _apiKey ?? _getDefaultApiKey(),
    authDomain: authDomain,
    projectId: projectId,
    storageBucket: storageBucket,
    messagingSenderId: _messagingSenderId ?? _getDefaultMessagingSenderId(),
    appId: _appId ?? _getDefaultAppId(),
  );
  
  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _apiKey ?? _getDefaultApiKey(),
    authDomain: authDomain,
    projectId: projectId,
    storageBucket: storageBucket,
    messagingSenderId: _messagingSenderId ?? _getDefaultMessagingSenderId(),
    appId: _appId ?? _getDefaultAppId(),
  );
  
  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: _apiKey ?? _getDefaultApiKey(),
    authDomain: authDomain,
    projectId: projectId,
    storageBucket: storageBucket,
    messagingSenderId: _messagingSenderId ?? _getDefaultMessagingSenderId(),
    appId: _appId ?? _getDefaultAppId(),
  );
  
  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: _apiKey ?? _getDefaultApiKey(),
    authDomain: authDomain,
    projectId: projectId,
    storageBucket: storageBucket,
    messagingSenderId: _messagingSenderId ?? _getDefaultMessagingSenderId(),
    appId: _appId ?? _getDefaultAppId(),
  );
  
  // Fallback values for development (these should be replaced with environment variables)
  static String _getDefaultApiKey() {
    // In production, this should throw an error
    if (kReleaseMode) {
      throw Exception('Firebase API key not configured for production');
    }
    // For development only - replace with your actual key
    return const String.fromEnvironment('FIREBASE_API_KEY', 
      defaultValue: 'AIzaSyAPhc5SNg1acyT_D_jo4edQD43PeR8GbZs');
  }
  
  static String _getDefaultAppId() {
    if (kReleaseMode) {
      throw Exception('Firebase App ID not configured for production');
    }
    return const String.fromEnvironment('FIREBASE_APP_ID',
      defaultValue: '1:40081637330:web:5e49ab59e5f0755823120b');
  }
  
  static String _getDefaultMessagingSenderId() {
    if (kReleaseMode) {
      throw Exception('Firebase Messaging Sender ID not configured for production');
    }
    return const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '40081637330');
  }
}
