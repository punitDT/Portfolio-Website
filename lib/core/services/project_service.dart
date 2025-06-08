import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mysite/core/models/project_model.dart';
import 'package:mysite/core/services/firebase_service.dart';
import 'package:mysite/core/services/storage_service.dart';

class ProjectService {
  static const String _collection = 'projects';
  static CollectionReference get _projectsRef =>
      FirebaseService.firestore.collection(_collection);

  // Get all active projects
  static Stream<List<ProjectModel>> getActiveProjects() {
    return _projectsRef
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final projects = snapshot.docs
              .map((doc) => ProjectModel.fromFirestore(doc))
              .toList();

          // Sort in memory: first by order, then by createdAt (descending)
          projects.sort((a, b) {
            final orderComparison = a.order.compareTo(b.order);
            if (orderComparison != 0) return orderComparison;
            return b.createdAt.compareTo(a.createdAt);
          });

          return projects;
        });
  }

  // Get all projects (for admin)
  static Stream<List<ProjectModel>> getAllProjects() {
    return _projectsRef
        .snapshots()
        .map((snapshot) {
          final projects = snapshot.docs
              .map((doc) => ProjectModel.fromFirestore(doc))
              .toList();

          // Sort in memory: first by order, then by createdAt (descending)
          projects.sort((a, b) {
            final orderComparison = a.order.compareTo(b.order);
            if (orderComparison != 0) return orderComparison;
            return b.createdAt.compareTo(a.createdAt);
          });

          return projects;
        });
  }

  // Get project by ID
  static Future<ProjectModel?> getProjectById(String id) async {
    try {
      final doc = await _projectsRef.doc(id).get();
      if (doc.exists) {
        return ProjectModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get project: ${e.toString()}');
    }
  }

  // Add new project
  static Future<String> addProject(ProjectModel project) async {
    try {
      final docRef = await _projectsRef.add(project.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add project: ${e.toString()}');
    }
  }

  // Update project
  static Future<void> updateProject(String id, ProjectModel project) async {
    try {
      await _projectsRef.doc(id).update(
            project.copyWith(updatedAt: DateTime.now()).toFirestore(),
          );
    } catch (e) {
      throw Exception('Failed to update project: ${e.toString()}');
    }
  }

  // Delete project (soft delete)
  static Future<void> deleteProject(String id) async {
    try {
      await _projectsRef.doc(id).update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to delete project: ${e.toString()}');
    }
  }

  // Update project orders in bulk
  static Future<void> updateProjectOrders(List<ProjectModel> projects) async {
    try {
      final batch = FirebaseService.firestore.batch();

      for (int i = 0; i < projects.length; i++) {
        final project = projects[i];
        if (project.id != null) {
          final docRef = _projectsRef.doc(project.id!);
          batch.update(docRef, {
            'order': i,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to update project orders: ${e.toString()}');
    }
  }

  // Permanently delete project
  static Future<void> permanentlyDeleteProject(String id) async {
    try {
      // Delete associated images from storage
      await StorageService.deleteProjectImages(id);

      // Delete project document from Firestore
      await _projectsRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to permanently delete project: ${e.toString()}');
    }
  }

  // Restore project
  static Future<void> restoreProject(String id) async {
    try {
      await _projectsRef.doc(id).update({
        'isActive': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to restore project: ${e.toString()}');
    }
  }
}
