import 'package:flutter/material.dart';
import 'package:mysite/core/services/public_firebase_service.dart';
import 'my_site.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize only public Firebase services for optimal performance
  try {
    await PublicFirebaseService.initialize();
    print('Public Firebase services initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    // App will show error state if Firebase is not available
  }

  runApp(const MySite());
}
