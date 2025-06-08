import 'package:flutter/material.dart';
import 'package:mysite/core/models/project_model.dart';
import 'package:mysite/core/models/service_model.dart';
import 'package:mysite/core/models/content_model.dart';
import 'package:mysite/core/services/project_service.dart';
import 'package:mysite/core/services/service_service.dart';
import 'package:mysite/core/services/content_service.dart';

import 'package:mysite/core/services/firebase_service.dart';


class DataProvider extends ChangeNotifier {
  List<ProjectModel> _projects = [];
  List<ServiceModel> _services = [];
  Map<String, String> _content = {};
  bool _isLoading = true;
  bool _useFirestore = false;
  String? _errorMessage;

  List<ProjectModel> get projects => _projects;
  List<ServiceModel> get services => _services;
  Map<String, String> get content => _content;
  bool get isLoading => _isLoading;
  bool get useFirestore => _useFirestore;
  String? get errorMessage => _errorMessage;

  // For admin compatibility
  List<ProjectModel> get staticProjects => _projects;

  // Static data removed - all data now comes from Firebase

  DataProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      _setLoading(true);

      // Always start with static data for immediate display
      _loadStaticData();
      _setLoading(false);

      // Try Firebase in background, but don't block the UI
      _tryFirebaseConnection();

    } catch (e) {
      print('Data initialization error: $e');
      _loadStaticData(); // Fallback to static data
      _setLoading(false);
    }
  }

  Future<void> _tryFirebaseConnection() async {
    print('Attempting Firebase connection...');

    try {
      // Initialize Firebase first
      await FirebaseService.initialize();
      print('Firebase initialized successfully');

      // Load data from Firestore only
      print('Loading data from Firestore...');
      _useFirestore = true;
      await _loadFromFirestore();
      print('Data loaded from Firestore successfully');
    } catch (e) {
      print('Firebase connection failed, using static data: $e');
      _useFirestore = false;
      // Continue with static data as fallback
    }
  }

  Future<void> _loadFromFirestore() async {
    try {
      // Load projects
      final projectsStream = ProjectService.getActiveProjects();
      projectsStream.listen((projects) {
        _projects = projects;
        notifyListeners();
      });

      // Load services
      final servicesStream = ServiceService.getActiveServices();
      servicesStream.listen((services) {
        _services = services;
        notifyListeners();
      });

      // Load content
      final contentStream = ContentService.getAllContent();
      contentStream.listen((contentList) {
        _content = {
          for (final item in contentList) item.key: item.value
        };
        notifyListeners();
      });

    } catch (e) {
      throw Exception('Failed to load data from Firestore: $e');
    }
  }

  void _loadStaticData() {
    // Static data removed - all data now comes from Firebase
    _projects = [];
    _services = [];
    _content = {
      'hello_tag': 'Hi there, Welcome to My Space',
      'your_name': "I'm Punit Patel,",
      'animation_txt1': ' Mobile Application Developer',
      'animation_txt2': ' UI/UX Designer',
      'animation_txt3': ' Web Developer',
      'contact_heading': "Let's try my service now!",
      'contact_sub_heading': "Let's work together and make everything super cute and super useful.",
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
    notifyListeners();
  }

  // Get content value with fallback
  String getContent(String key, {String defaultValue = ''}) {
    return _content[key] ?? defaultValue;
  }

  // Refresh data from Firestore
  Future<void> refreshData() async {
    if (_useFirestore) {
      await _loadFromFirestore();
    }
  }

  // Refresh services specifically
  Future<void> refreshServices() async {
    if (_useFirestore) {
      try {
        final servicesStream = ServiceService.getAllServices(); // Get all for admin
        servicesStream.listen((services) {
          _services = services;
          notifyListeners();
        });
      } catch (e) {
        print('Failed to refresh services: $e');
      }
    }
  }

  // Refresh projects specifically
  Future<void> refreshProjects() async {
    if (_useFirestore) {
      try {
        final projectsStream = ProjectService.getAllProjects(); // Get all for admin
        projectsStream.listen((projects) {
          _projects = projects;
          notifyListeners();
        });
      } catch (e) {
        print('Failed to refresh projects: $e');
      }
    }
  }

  // Refresh content specifically
  Future<void> refreshContent() async {
    if (_useFirestore) {
      try {
        final contentStream = ContentService.getAllContent();
        contentStream.listen((contentList) {
          _content = {
            for (final item in contentList) item.key: item.value
          };
          notifyListeners();
        });
      } catch (e) {
        print('Failed to refresh content: $e');
      }
    }
  }

  // Switch to Firestore mode (after admin login)
  Future<void> enableFirestoreMode() async {
    if (!_useFirestore) {
      _useFirestore = true;
      await _loadFromFirestore();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
