import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mysite/core/services/firebase_service.dart';

class AdminAuthService {
  static const String _adminCollection = 'admin_users';
  
  // Demo admin email (password should be set in Firebase Console)
  static const String demoAdminEmail = 'punit.mece@gmail.com';

  // Check if user is admin by checking Firestore admin collection
  static Future<bool> isUserAdmin(String uid) async {
    try {
      // First check if this is the demo admin by email
      final user = FirebaseService.currentUser;
      if (user?.email == demoAdminEmail) {
        print('Demo admin detected by email, granting admin access');
        return true;
      }

      // Then check Firestore admin collection
      final doc = await FirebaseService.firestore
          .collection(_adminCollection)
          .doc(uid)
          .get();

      return doc.exists && (doc.data()?['isAdmin'] == true);
    } catch (e) {
      // If Firestore check fails, fall back to email check for demo
      final user = FirebaseService.currentUser;
      final isDemoAdmin = user?.email == demoAdminEmail;
      print('Firestore admin check failed, falling back to email check: $isDemoAdmin');
      return isDemoAdmin;
    }
  }

  // Create admin user in Firestore (call this once to set up admin)
  static Future<void> createAdminUser(String uid, String email) async {
    try {
      await FirebaseService.firestore
          .collection(_adminCollection)
          .doc(uid)
          .set({
        'email': email,
        'isAdmin': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to create admin user: $e');
    }
  }

  // Update last login time
  static Future<void> updateLastLogin(String uid) async {
    try {
      await FirebaseService.firestore
          .collection(_adminCollection)
          .doc(uid)
          .update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to update last login: $e');
    }
  }

  // Sign in and verify admin status
  static Future<bool> signInAdmin(String email, String password) async {
    try {
      final userCredential = await FirebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential?.user != null) {
        final uid = userCredential!.user!.uid;
        final userEmail = userCredential!.user!.email;

        // For demo admin, allow access (admin user should already exist in Firebase)
        if (userEmail == demoAdminEmail && userEmail != null) {
          print('Demo admin detected, granting access...');
          try {
            await updateLastLogin(uid);
            print('Demo admin access granted');
            return true;
          } catch (e) {
            print('Failed to update last login, but allowing demo access: $e');
            return true; // Allow demo admin even if Firestore write fails
          }
        }

        // For other users, check if user is admin
        final isAdmin = await isUserAdmin(uid);

        if (isAdmin) {
          // Update last login
          await updateLastLogin(uid);
          return true;
        } else {
          // Sign out non-admin user
          await FirebaseService.signOut();
          throw Exception('Access denied. Admin privileges required.');
        }
      }

      return false;
    } catch (e) {
      throw Exception('Admin login failed: ${e.toString()}');
    }
  }

  // Note: Admin user should be created manually in Firebase Console
  // This ensures proper security and avoids hardcoded passwords

  // Get admin user info
  static Future<Map<String, dynamic>?> getAdminInfo(String uid) async {
    try {
      final doc = await FirebaseService.firestore
          .collection(_adminCollection)
          .doc(uid)
          .get();
      
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  // List all admin users (for super admin functionality)
  static Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final querySnapshot = await FirebaseService.firestore
          .collection(_adminCollection)
          .where('isAdmin', isEqualTo: true)
          .get();
      
      return querySnapshot.docs.map((doc) => {
        'uid': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
