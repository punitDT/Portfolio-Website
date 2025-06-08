import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mysite/core/models/service_model.dart';
import 'package:mysite/core/services/firebase_service.dart';
import 'package:mysite/core/services/storage_service.dart';

class ServiceService {
  static const String _collection = 'services';
  static CollectionReference get _servicesRef =>
      FirebaseService.firestore.collection(_collection);

  // Get all active services
  static Stream<List<ServiceModel>> getActiveServices() {
    return _servicesRef
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final services = snapshot.docs
              .map((doc) => ServiceModel.fromFirestore(doc))
              .toList();

          // Sort by order first, then by createdAt
          services.sort((a, b) {
            if (a.order != b.order) {
              return a.order.compareTo(b.order);
            }
            return a.createdAt.compareTo(b.createdAt);
          });

          return services;
        });
  }

  // Get all services (for admin)
  static Stream<List<ServiceModel>> getAllServices() {
    return _servicesRef
        .snapshots()
        .map((snapshot) {
          final services = snapshot.docs
              .map((doc) => ServiceModel.fromFirestore(doc))
              .toList();

          // Sort by order first, then by createdAt
          services.sort((a, b) {
            if (a.order != b.order) {
              return a.order.compareTo(b.order);
            }
            return a.createdAt.compareTo(b.createdAt);
          });

          return services;
        });
  }

  // Get service by ID
  static Future<ServiceModel?> getServiceById(String id) async {
    try {
      final doc = await _servicesRef.doc(id).get();
      if (doc.exists) {
        return ServiceModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get service: ${e.toString()}');
    }
  }

  // Add new service
  static Future<String> addService(ServiceModel service) async {
    try {
      final docRef = await _servicesRef.add(service.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add service: ${e.toString()}');
    }
  }

  // Update service
  static Future<void> updateService(String id, ServiceModel service) async {
    try {
      await _servicesRef.doc(id).update(
            service.copyWith(updatedAt: DateTime.now()).toFirestore(),
          );
    } catch (e) {
      throw Exception('Failed to update service: ${e.toString()}');
    }
  }

  // Delete service (soft delete)
  static Future<void> deleteService(String id) async {
    try {
      await _servicesRef.doc(id).update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to delete service: ${e.toString()}');
    }
  }

  // Permanently delete service
  static Future<void> permanentlyDeleteService(String id) async {
    try {
      // Delete associated images first
      await StorageService.deleteServiceImages(id);

      // Then delete the service document
      await _servicesRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to permanently delete service: ${e.toString()}');
    }
  }

  // Restore service
  static Future<void> restoreService(String id) async {
    try {
      await _servicesRef.doc(id).update({
        'isActive': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to restore service: ${e.toString()}');
    }
  }

  // Update service order
  static Future<void> updateServiceOrder(String id, int newOrder) async {
    try {
      await _servicesRef.doc(id).update({
        'order': newOrder,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update service order: ${e.toString()}');
    }
  }

  // Reorder services - update multiple services at once
  static Future<void> reorderServices(List<ServiceModel> services) async {
    try {
      final batch = FirebaseService.firestore.batch();

      for (int i = 0; i < services.length; i++) {
        final service = services[i];
        if (service.id != null) {
          final docRef = _servicesRef.doc(service.id!);
          batch.update(docRef, {
            'order': i,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to reorder services: ${e.toString()}');
    }
  }

  // Get next order value for new services
  static Future<int> getNextOrderValue() async {
    try {
      final snapshot = await _servicesRef
          .orderBy('order', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return 0;
      }

      final lastService = ServiceModel.fromFirestore(snapshot.docs.first);
      return lastService.order + 1;
    } catch (e) {
      // If there's an error, return 0 as default
      return 0;
    }
  }
}
