import 'package:flutter/foundation.dart';
import 'package:mysite/core/models/project_model.dart';
import 'package:mysite/core/models/service_model.dart';
import 'package:mysite/core/services/public_firebase_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:async';

/// Optimized data provider for public portfolio
/// Only loads data from Firebase, no static fallbacks
class PublicDataProvider extends ChangeNotifier {
  List<ProjectModel> _projects = [];
  List<ServiceModel> _services = [];
  Map<String, String> _content = {};
  bool _isLoading = true;
  String? _error;

  // Stream subscriptions
  StreamSubscription<List<ProjectModel>>? _projectsSubscription;
  StreamSubscription<List<ServiceModel>>? _servicesSubscription;
  StreamSubscription<Map<String, String>>? _contentSubscription;

  // Getters
  List<ProjectModel> get projects => _projects;
  List<ServiceModel> get services => _services;
  Map<String, String> get content => _content;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _projects.isNotEmpty || _services.isNotEmpty;

  PublicDataProvider() {
    _initializeData();
  }

  /// Initialize data from Firebase
  Future<void> _initializeData() async {
    try {
      _setLoading(true);
      _clearError();

      // Initialize Firebase if not already done
      if (!PublicFirebaseService.isInitialized) {
        await PublicFirebaseService.initialize();
      }

      // Test connection
      final isConnected = await PublicFirebaseService.testConnection();
      if (!isConnected) {
        throw Exception('Unable to connect to Firebase');
      }

      // Set up real-time listeners
      _setupDataListeners();

    } catch (e) {
      _setError('Failed to initialize data: ${e.toString()}');
      print('PublicDataProvider initialization error: $e');
    }
  }

  /// Set up real-time data listeners
  void _setupDataListeners() {
    // Listen to projects
    _projectsSubscription = PublicFirebaseService.getActiveProjects().listen(
      (projects) {
        _projects = projects;
        _checkLoadingComplete();
        notifyListeners();
      },
      onError: (error) {
        print('Projects stream error: $error');
        _setError('Failed to load projects');
      },
    );

    // Listen to services
    _servicesSubscription = PublicFirebaseService.getActiveServices().listen(
      (services) {
        _services = services;
        _checkLoadingComplete();
        notifyListeners();
      },
      onError: (error) {
        print('Services stream error: $error');
        _setError('Failed to load services');
      },
    );

    // Listen to content
    _contentSubscription = PublicFirebaseService.getContent().listen(
      (content) {
        _content = content;
        _checkLoadingComplete();
        notifyListeners();
      },
      onError: (error) {
        print('Content stream error: $error');
        _setError('Failed to load content');
      },
    );
  }

  /// Check if all data has been loaded
  void _checkLoadingComplete() {
    if (_isLoading && (_projects.isNotEmpty || _services.isNotEmpty || _content.isNotEmpty)) {
      _setLoading(false);
    }
  }

  /// Get content by key with fallback
  String getContent(String key, {String? defaultValue}) {
    return _content[key] ?? defaultValue ?? '';
  }

  /// Refresh all data
  Future<void> refresh() async {
    try {
      _setLoading(true);
      _clearError();
      
      // Cancel existing subscriptions
      await _cancelSubscriptions();
      
      // Reinitialize
      await _initializeData();
    } catch (e) {
      _setError('Failed to refresh data: ${e.toString()}');
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error state
  void _setError(String error) {
    _error = error;
    _setLoading(false);
    notifyListeners();
  }

  /// Clear error state
  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  /// Force refresh data from Firestore (clears cache)
  Future<void> forceRefreshData() async {
    try {
      _setLoading(true);
      _clearError();

      // Clear image cache
      await _clearImageCache();

      // Clear existing data first
      _content.clear();
      _projects.clear();
      _services.clear();

      // Cancel existing subscriptions
      await _cancelSubscriptions();

      // Reinitialize with fresh data
      await _initializeData();
    } catch (e) {
      _setError('Failed to force refresh data: ${e.toString()}');
    }
  }

  /// Clear image cache
  Future<void> _clearImageCache() async {
    try {
      // Clear cached network images
      await CachedNetworkImage.evictFromCache('');
      // Clear all cached images
      final cacheManager = DefaultCacheManager();
      await cacheManager.emptyCache();
    } catch (e) {
      print('Failed to clear image cache: $e');
    }
  }

  /// Cancel all subscriptions
  Future<void> _cancelSubscriptions() async {
    await _projectsSubscription?.cancel();
    await _servicesSubscription?.cancel();
    await _contentSubscription?.cancel();
    
    _projectsSubscription = null;
    _servicesSubscription = null;
    _contentSubscription = null;
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
