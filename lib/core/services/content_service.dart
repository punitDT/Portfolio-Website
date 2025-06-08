import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mysite/core/models/content_model.dart';
import 'package:mysite/core/services/firebase_service.dart';

class ContentService {
  static const String _collection = 'content';
  static CollectionReference get _contentRef =>
      FirebaseService.firestore.collection(_collection);

  // Get all content
  static Stream<List<ContentModel>> getAllContent() {
    return _contentRef
        .snapshots()
        .map((snapshot) {
          final content = snapshot.docs
              .map((doc) => ContentModel.fromFirestore(doc))
              .toList();

          // Sort in memory by key
          content.sort((a, b) => a.key.compareTo(b.key));

          return content;
        });
  }

  // Get content by key
  static Future<ContentModel?> getContentByKey(String key) async {
    try {
      final querySnapshot = await _contentRef
          .where('key', isEqualTo: key)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return ContentModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get content: ${e.toString()}');
    }
  }

  // Get content value by key
  static Future<String> getContentValue(String key, {String defaultValue = ''}) async {
    try {
      final content = await getContentByKey(key);
      return content?.value ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  // Update or create content
  static Future<void> updateContent(String key, String value, {String type = 'text'}) async {
    try {
      final querySnapshot = await _contentRef
          .where('key', isEqualTo: key)
          .limit(1)
          .get();

      final content = ContentModel(
        key: key,
        value: value,
        type: type,
        updatedAt: DateTime.now(),
      );

      if (querySnapshot.docs.isNotEmpty) {
        // Update existing content
        await _contentRef.doc(querySnapshot.docs.first.id).update(
          content.toFirestore(),
        );
      } else {
        // Create new content
        await _contentRef.add(content.toFirestore());
      }
    } catch (e) {
      throw Exception('Failed to update content: ${e.toString()}');
    }
  }

  // Delete content
  static Future<void> deleteContent(String key) async {
    try {
      final querySnapshot = await _contentRef
          .where('key', isEqualTo: key)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete content: ${e.toString()}');
    }
  }

  // Initialize default content
  static Future<void> initializeDefaultContent() async {
    final defaultContent = {
      'hello_tag': 'Hi there, Welcome to My Space',
      'your_name': "I'm Punit Patel,",
      'animation_txt1': ' Mobile Application Developer',
      'animation_txt2': ' UI/UX Designer',
      'animation_txt3': ' Web Developer',
      'contact_heading': "Let's try my service now!",
      'contact_sub_heading': "Let's work together and make everything super cute and super useful.",
      'contact_section_heading': 'Get in Touch',
      'contact_section_sub_heading': 'If you want to avail my services you can contact me at the links below.',
      'mini_description': "Freelancer providing services for programming and design content needs. Join me down below and let's get started!",
      'profile_image_url': 'https://images.unsplash.com/photo-1503443207922-dff7d543fd0e?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=627&q=80',
      'services_sub_heading': "Since the beginning of my journey as a freelance designer and developer, I've worked in startups and collaborated with talented people to create digital products for both business and consumer use. I offer a wide range of services, including programming and development.",
      'portfolio_sub_heading': "Since the beginning of my journey as a developer, I have created digital products for business and consumer use. This is a little bit.",
      'github_url': 'https://github.com/punitDT',
      'linkedin_url': 'https://www.linkedin.com/in/punit-patel-67906874',
      'whatsapp_url': 'https://api.whatsapp.com/send?phone=9724117174',
      'upwork_url': 'https://www.upwork.com/freelancers/~01e0dff917f3bdff40',
      'resume_url': 'https://drive.google.com/file/d/11SKV1YlDUEJJq5B7JYAFjSi8k2nmp-HC/view?usp=sharing',
    };

    for (final entry in defaultContent.entries) {
      final existing = await getContentByKey(entry.key);
      if (existing == null) {
        await updateContent(entry.key, entry.value);
      }
    }
  }
}
