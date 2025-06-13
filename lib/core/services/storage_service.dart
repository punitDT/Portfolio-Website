import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mysite/core/services/firebase_service.dart';

class StorageService {
  // Upload banner image for project (user-specific path)
  static Future<String> uploadProjectBanner({
    required String projectId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    try {
      // Get current authenticated user
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to upload files');
      }

      // Use user-specific path as required by Firebase Storage rules
      final cleanFileName = fileName.replaceAll(' ', '_').toLowerCase();
      final storageFileName = '${projectId}_banner_$cleanFileName';
      final storagePath = 'user_uploads/${currentUser.uid}/$storageFileName';

      final ref = FirebaseService.storage
          .ref()
          .child(storagePath);

      final uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(
          contentType: _getContentType(fileName),
          customMetadata: {
            'projectId': projectId,
            'type': 'banner',
            'uploadedAt': DateTime.now().toIso8601String(),
            'uploadedBy': currentUser.uid,
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('Banner uploaded successfully to: $storagePath');
      return downloadUrl;
    } catch (e) {
      print('Error uploading banner: $e');
      throw Exception('Failed to upload banner: ${e.toString()}');
    }
  }

  // Upload icon image for project (user-specific path)
  static Future<String> uploadProjectIcon({
    required String projectId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    try {
      // Get current authenticated user
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to upload files');
      }

      // Use user-specific path as required by Firebase Storage rules
      final cleanFileName = fileName.replaceAll(' ', '_').toLowerCase();
      final storageFileName = '${projectId}_icon_$cleanFileName';
      final storagePath = 'user_uploads/${currentUser.uid}/$storageFileName';

      final ref = FirebaseService.storage
          .ref()
          .child(storagePath);

      final uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(
          contentType: _getContentType(fileName),
          customMetadata: {
            'projectId': projectId,
            'type': 'icon',
            'uploadedAt': DateTime.now().toIso8601String(),
            'uploadedBy': currentUser.uid,
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('Icon uploaded successfully to: $storagePath');
      return downloadUrl;
    } catch (e) {
      print('Error uploading icon: $e');
      throw Exception('Failed to upload icon: ${e.toString()}');
    }
  }

  // Upload icon image for service (user-specific path)
  static Future<String> uploadServiceIcon({
    required String serviceId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    try {
      // Get current authenticated user
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to upload files');
      }

      // Use user-specific path as required by Firebase Storage rules
      final cleanFileName = fileName.replaceAll(' ', '_').toLowerCase();
      final storageFileName = '${serviceId}_icon_$cleanFileName';
      final storagePath = 'user_uploads/${currentUser.uid}/$storageFileName';

      final ref = FirebaseService.storage
          .ref()
          .child(storagePath);

      final uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(
          contentType: _getContentType(fileName),
          customMetadata: {
            'serviceId': serviceId,
            'type': 'service_icon',
            'uploadedAt': DateTime.now().toIso8601String(),
            'uploadedBy': currentUser.uid,
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('Service icon uploaded successfully to: $storagePath');
      return downloadUrl;
    } catch (e) {
      print('Error uploading service icon: $e');
      throw Exception('Failed to upload service icon: ${e.toString()}');
    }
  }

  // Upload slider image for project (user-specific path)
  static Future<String> uploadProjectSliderImage({
    required String projectId,
    required String fileName,
    required Uint8List fileBytes,
    required int imageIndex,
  }) async {
    try {
      // Get current authenticated user
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to upload files');
      }

      // Use user-specific path as required by Firebase Storage rules
      final cleanFileName = fileName.replaceAll(' ', '_').toLowerCase();
      final storageFileName = '${projectId}_slider_${imageIndex}_$cleanFileName';
      final storagePath = 'user_uploads/${currentUser.uid}/$storageFileName';

      final ref = FirebaseService.storage
          .ref()
          .child(storagePath);

      final uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(
          contentType: _getContentType(fileName),
          customMetadata: {
            'projectId': projectId,
            'type': 'slider_image',
            'imageIndex': imageIndex.toString(),
            'uploadedAt': DateTime.now().toIso8601String(),
            'uploadedBy': currentUser.uid,
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('Slider image uploaded successfully to: $storagePath');
      return downloadUrl;
    } catch (e) {
      print('Error uploading slider image: $e');
      throw Exception('Failed to upload slider image: ${e.toString()}');
    }
  }

  // Delete project images when project is deleted
  static Future<void> deleteProjectImages(String projectId) async {
    try {
      // Get current authenticated user
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) {
        print('Warning: No authenticated user, cannot delete project images');
        return;
      }

      // List all files in user's upload directory
      final userUploadsRef = FirebaseService.storage.ref().child('user_uploads/${currentUser.uid}');
      final listResult = await userUploadsRef.listAll();

      // Delete any files that start with the project ID
      for (final item in listResult.items) {
        if (item.name.startsWith('${projectId}_')) {
          try {
            await item.delete();
            print('Deleted: ${item.fullPath}');
          } catch (e) {
            print('Failed to delete ${item.fullPath}: $e');
          }
        }
      }
    } catch (e) {
      // Don't throw error for cleanup operations
      print('Warning: Failed to delete some project images: $e');
    }
  }

  // Delete service images when service is deleted
  static Future<void> deleteServiceImages(String serviceId) async {
    try {
      // Get current authenticated user
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) {
        print('Warning: No authenticated user, cannot delete service images');
        return;
      }

      // List all files in user's upload directory
      final userUploadsRef = FirebaseService.storage.ref().child('user_uploads/${currentUser.uid}');
      final listResult = await userUploadsRef.listAll();

      // Delete any files that start with the service ID
      for (final item in listResult.items) {
        if (item.name.startsWith('${serviceId}_')) {
          try {
            await item.delete();
            print('Deleted service image: ${item.fullPath}');
          } catch (e) {
            print('Failed to delete ${item.fullPath}: $e');
          }
        }
      }
    } catch (e) {
      // Don't throw error for cleanup operations
      print('Warning: Failed to delete some service images: $e');
    }
  }

  // Get content type based on file extension
  static String _getContentType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }

  // Generate unique project ID for new projects
  static String generateProjectId() {
    return 'project_${DateTime.now().millisecondsSinceEpoch}';
  }
}
