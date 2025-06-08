import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mysite/core/models/project_model.dart';
import 'package:mysite/core/services/project_service.dart';
import 'package:mysite/core/services/storage_service.dart';
import 'package:mysite/core/services/firebase_service.dart';
import 'package:mysite/core/services/admin_auth_service.dart';
import 'dart:typed_data';

class ProjectFormDialog extends StatefulWidget {
  final ProjectModel? project;
  final bool isFirestoreEnabled;

  const ProjectFormDialog({
    Key? key,
    this.project,
    required this.isFirestoreEnabled,
  }) : super(key: key);

  @override
  State<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  final _bannerUrlController = TextEditingController();
  final _iconUrlController = TextEditingController();


  bool _isLoading = false;
  String? _selectedBannerFileName;
  String? _selectedIconFileName;
  Uint8List? _selectedBannerBytes;
  Uint8List? _selectedIconBytes;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _titleController.text = widget.project!.title;
      _descriptionController.text = widget.project!.description;
      _linkController.text = widget.project!.link ?? '';
      _bannerUrlController.text = widget.project!.bannerUrl;
      _iconUrlController.text = widget.project!.iconUrl;

    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _bannerUrlController.dispose();
    _iconUrlController.dispose();

    super.dispose();
  }

  Future<void> _pickFile(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // This ensures we get the file bytes
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.bytes == null) {
          throw Exception('Failed to read file data');
        }

        setState(() {
          switch (type) {
            case 'banner':
              _selectedBannerFileName = file.name;
              _selectedBannerBytes = file.bytes;
              _bannerUrlController.text = 'Selected: ${file.name}';
              break;
            case 'icon':
              _selectedIconFileName = file.name;
              _selectedIconBytes = file.bytes;
              _iconUrlController.text = 'Selected: ${file.name}';
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('Starting project save process...');
      final now = DateTime.now();
      final projectId = widget.project?.id ?? StorageService.generateProjectId();
      print('Project ID: $projectId');

      // Handle file uploads if files are selected
      String bannerUrl = _bannerUrlController.text.trim();
      String iconUrl = _iconUrlController.text.trim();
      print('Initial URLs - Banner: $bannerUrl, Icon: $iconUrl');

      // Validate URLs before proceeding
      // Validate final URLs (allow Selected: for files that will be uploaded later)
      if (bannerUrl.isEmpty) {
        throw Exception('Banner image is required. Please provide a valid image URL or select a file.');
      }

      if (iconUrl.isEmpty) {
        throw Exception('Icon image is required. Please provide a valid image URL or select a file.');
      }

      // For files that will be uploaded, ensure we have the file data
      if (bannerUrl.startsWith('Selected:') && _selectedBannerBytes == null) {
        throw Exception('Banner file not properly loaded. Please reselect the file.');
      }

      if (iconUrl.startsWith('Selected:') && _selectedIconBytes == null) {
        throw Exception('Icon file not properly loaded. Please reselect the file.');
      }

      // For editing existing projects, allow keeping existing images
      if (widget.project != null) {
        if (bannerUrl.isEmpty) {
          bannerUrl = widget.project!.bannerUrl;
        }
        if (iconUrl.isEmpty) {
          iconUrl = widget.project!.iconUrl;
        }
      }

      final projectData = ProjectModel(
        id: projectId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        link: _linkController.text.trim().isEmpty ? null : _linkController.text.trim(),
        bannerUrl: bannerUrl,
        iconUrl: iconUrl,
        createdAt: widget.project?.createdAt ?? now,
        updatedAt: now,
        isActive: widget.project?.isActive ?? true,
        order: widget.project?.order ?? 0,
      );

      print('Project data prepared: ${projectData.title}');
      print('Final URLs - Banner: ${projectData.bannerUrl}, Icon: ${projectData.iconUrl}');

      if (widget.isFirestoreEnabled) {
        print('Saving to Firestore...');

        // Check authentication status first
        final currentUser = FirebaseService.currentUser;
        print('Current user: ${currentUser?.email ?? "Not authenticated"}');
        print('User UID: ${currentUser?.uid ?? "No UID"}');

        if (currentUser == null) {
          throw Exception('Authentication required. Please log in to continue.');
        }

        // Verify current user after potential re-authentication
        final updatedUser = FirebaseService.currentUser;
        if (updatedUser == null) {
          throw Exception('Authentication failed. No user found after login attempt.');
        }

        // Check if user is admin (this is now more lenient for demo admin)
        try {
          final isAdmin = await AdminAuthService.isUserAdmin(updatedUser.uid);
          print('Is user admin: $isAdmin');

          if (!isAdmin) {
            throw Exception('Access denied. Admin privileges required.');
          }
        } catch (adminCheckError) {
          print('Admin check failed: $adminCheckError');
          throw Exception('Admin verification failed: $adminCheckError');
        }

        // Check Firebase connection before attempting save
        try {
          final connectionTest = await FirebaseService.testConnection();
          if (!connectionTest) {
            throw Exception('Firebase connection test failed');
          }
          print('Firebase connection test passed');
        } catch (networkError) {
          print('Firebase network error: $networkError');
          // Get detailed status for debugging
          final status = await FirebaseService.getFirebaseStatus();
          print('Firebase status: $status');
          throw Exception('Firebase connection failed. Please check your internet connection and Firebase configuration. Details: $networkError');
        }

        // Now that authentication is confirmed, handle file uploads
        // Upload banner if a new file is selected
        if (_selectedBannerBytes != null && _selectedBannerFileName != null) {
          print('Uploading banner image after authentication...');
          bannerUrl = await StorageService.uploadProjectBanner(
            projectId: projectId,
            fileName: _selectedBannerFileName!,
            fileBytes: _selectedBannerBytes!,
          );
          print('Banner uploaded: $bannerUrl');
        } else if (widget.project != null && !bannerUrl.startsWith('Selected:')) {
          // Keep existing banner URL if no new file uploaded
          bannerUrl = widget.project!.bannerUrl;
        }

        // Upload icon if a new file is selected
        if (_selectedIconBytes != null && _selectedIconFileName != null) {
          print('Uploading icon image after authentication...');
          iconUrl = await StorageService.uploadProjectIcon(
            projectId: projectId,
            fileName: _selectedIconFileName!,
            fileBytes: _selectedIconBytes!,
          );
          print('Icon uploaded: $iconUrl');
        } else if (widget.project != null && !iconUrl.startsWith('Selected:')) {
          // Keep existing icon URL if no new file uploaded
          iconUrl = widget.project!.iconUrl;
        }

        // Update project data with new URLs if uploads occurred
        if ((_selectedBannerBytes != null && _selectedBannerFileName != null) ||
            (_selectedIconBytes != null && _selectedIconFileName != null)) {
          final updatedProjectData = projectData.copyWith(
            bannerUrl: bannerUrl,
            iconUrl: iconUrl,
          );

          // Save to Firestore with updated URLs
          if (widget.project == null) {
            print('Adding new project with uploaded images...');
            await ProjectService.addProject(updatedProjectData);
            print('New project added successfully');
          } else {
            print('Updating existing project with uploaded images...');
            await ProjectService.updateProject(widget.project!.id!, updatedProjectData);
            print('Project updated successfully');
          }
        } else {
          // Save to Firestore with original URLs
          if (widget.project == null) {
            print('Adding new project...');
            await ProjectService.addProject(projectData);
            print('New project added successfully');
          } else {
            print('Updating existing project with ID: ${widget.project!.id}');
            await ProjectService.updateProject(widget.project!.id!, projectData);
            print('Project updated successfully');
          }
        }

        if (mounted) {
          Navigator.of(context).pop();

          String message = widget.project == null
              ? 'Project added to Firestore successfully'
              : 'Project updated in Firestore successfully';

          if (_selectedBannerBytes != null || _selectedIconBytes != null) {
            message += ' (with uploaded images)';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Save to local storage/static data for demo
        await _saveToLocalStorage(projectData);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.project == null
                  ? 'Project added to local storage (demo mode)'
                  : 'Project updated in local storage (demo mode)'),
              backgroundColor: Colors.blue,
              action: SnackBarAction(
                label: 'Configure Firebase',
                textColor: Colors.white,
                onPressed: () {
                  _showFirebaseSetupDialog();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error in _saveProject: $e');
      if (mounted) {
        String errorMessage = 'Error: ${e.toString()}';

        // Provide more specific error messages for common Firebase errors
        if (e.toString().contains('permission-denied')) {
          errorMessage = 'Permission denied. Please check your Firebase authentication and security rules.';
        } else if (e.toString().contains('network-request-failed')) {
          errorMessage = 'Network error. Please check your internet connection and try again.';
        } else if (e.toString().contains('unavailable')) {
          errorMessage = 'Firebase service is temporarily unavailable. Please try again later.';
        } else if (e.toString().contains('invalid-argument')) {
          errorMessage = 'Invalid data provided. Please check all fields and try again.';
        } else if (e.toString().contains('unauthenticated')) {
          errorMessage = 'Authentication required. Please log in again.';
        } else if (e.toString().contains('not-found')) {
          errorMessage = 'Project not found. It may have been deleted.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Details',
              textColor: Colors.white,
              onPressed: () {
                _showErrorDialog(e.toString());
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveToLocalStorage(ProjectModel project) async {
    // Simulate saving to local storage
    await Future.delayed(const Duration(milliseconds: 500));

    // In a real implementation, you could save to:
    // - SharedPreferences
    // - Local database (SQLite)
    // - Local JSON file
    // - Browser localStorage

    print('Project saved to local storage: ${project.title}');
    print('Project ID: ${project.id}');
  }

  void _showFirebaseSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configure Firebase'),
        content: const Text(
          'To save projects permanently, configure Firebase:\n\n'
          '1. Update lib/firebase_options.dart with your Firebase config\n'
          '2. Enable Authentication and Firestore in Firebase Console\n'
          '3. Restart the app\n\n'
          'See FIREBASE_SETUP.md for detailed instructions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String errorDetails) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Details'),
        content: SingleChildScrollView(
          child: Text(
            errorDetails,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // Copy to clipboard functionality could be added here
              Navigator.of(context).pop();
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(widget.project == null ? 'Add Project' : 'Edit Project'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title Field (Required)
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Field (Required)
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Link Field (Optional)
                TextFormField(
                  controller: _linkController,
                  decoration: const InputDecoration(
                    labelText: 'Project Link (optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                    hintText: 'https://example.com',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final uri = Uri.tryParse(value);
                      if (uri == null || !uri.hasAbsolutePath) {
                        return 'Please enter a valid URL';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Banner URL/Upload with Preview
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _bannerUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Banner Image *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.image),
                              hintText: 'URL or select file',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Banner image is required';
                              }
                              // Allow "Selected:" text when file is selected
                              if (value.startsWith('Selected:') && _selectedBannerBytes != null) {
                                return null; // Valid - file is selected
                              }
                              // Allow HTTP URLs
                              if (value.startsWith('http')) {
                                return null; // Valid URL
                              }
                              // Allow asset paths
                              if (value.startsWith('assets/')) {
                                return null; // Valid asset path
                              }
                              // If it's "Selected:" but no file bytes, show error
                              if (value.startsWith('Selected:')) {
                                return 'Please wait for file to be processed';
                              }
                              return null;
                            },
                            onChanged: (value) => setState(() {}), // Trigger rebuild for preview
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _pickFile('banner'),
                          icon: const Icon(Icons.upload_file),
                          tooltip: 'Upload Banner',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Banner Preview
                    if (_bannerUrlController.text.isNotEmpty || (widget.project != null && widget.project!.bannerUrl.isNotEmpty))
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _bannerUrlController.text.startsWith('Selected:')
                              ? Container(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green, size: 40),
                                        const SizedBox(height: 8),
                                        Text(
                                          'File Selected: ${_selectedBannerFileName ?? "Unknown"}',
                                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                        ),
                                        const Text(
                                          'Ready to upload',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : (_bannerUrlController.text.startsWith('http') ||
                                 (widget.project != null && widget.project!.bannerUrl.startsWith('http')))
                                  ? Image.network(
                                      _bannerUrlController.text.isNotEmpty
                                          ? _bannerUrlController.text
                                          : widget.project!.bannerUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.error, color: Colors.red),
                                              Text('Failed to load image'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Text('Invalid image URL'),
                                      ),
                                    ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Icon URL/Upload with Preview
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _iconUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Icon Image *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.apps),
                              hintText: 'URL or select file',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Icon image is required';
                              }
                              // Allow "Selected:" text when file is selected
                              if (value.startsWith('Selected:') && _selectedIconBytes != null) {
                                return null; // Valid - file is selected
                              }
                              // Allow HTTP URLs
                              if (value.startsWith('http')) {
                                return null; // Valid URL
                              }
                              // Allow asset paths
                              if (value.startsWith('assets/')) {
                                return null; // Valid asset path
                              }
                              // If it's "Selected:" but no file bytes, show error
                              if (value.startsWith('Selected:')) {
                                return 'Please wait for file to be processed';
                              }
                              return null;
                            },
                            onChanged: (value) => setState(() {}), // Trigger rebuild for preview
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _pickFile('icon'),
                          icon: const Icon(Icons.upload_file),
                          tooltip: 'Upload Icon',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Icon Preview
                    if (_iconUrlController.text.isNotEmpty || (widget.project != null && widget.project!.iconUrl.isNotEmpty))
                      Container(
                        height: 60,
                        width: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _iconUrlController.text.startsWith('Selected:')
                              ? Container(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'File: ${_selectedIconFileName ?? "Unknown"}',
                                          style: const TextStyle(color: Colors.green, fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : (_iconUrlController.text.startsWith('http') ||
                                 (widget.project != null && widget.project!.iconUrl.startsWith('http')))
                                  ? Image.network(
                                      _iconUrlController.text.isNotEmpty
                                          ? _iconUrlController.text
                                          : widget.project!.iconUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.error, color: Colors.red),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image),
                                    ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Info text
                if (!widget.isFirestoreEnabled)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Demo Mode: Projects will be saved to local storage. Configure Firebase for permanent storage.',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProject,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(widget.project == null
                  ? (widget.isFirestoreEnabled ? 'Add Project' : 'Add Project (Demo)')
                  : (widget.isFirestoreEnabled ? 'Update Project' : 'Update Project (Demo)')),
        ),
      ],
    );
  }
}
