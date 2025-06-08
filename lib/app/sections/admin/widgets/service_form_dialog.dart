import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:mysite/core/models/service_model.dart';
import 'package:mysite/core/services/service_service.dart';
import 'package:mysite/core/services/firebase_service.dart';
import 'package:mysite/core/services/storage_service.dart';

class ServiceFormDialog extends StatefulWidget {
  final ServiceModel? service; // null for add, non-null for edit
  final bool isFirestoreEnabled;

  const ServiceFormDialog({
    Key? key,
    this.service,
    required this.isFirestoreEnabled,
  }) : super(key: key);

  @override
  State<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconUrlController = TextEditingController();
  final _toolsController = TextEditingController();
  final _orderController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  // Image upload variables
  Uint8List? _selectedIconBytes;
  String? _selectedIconFileName;
  bool _useUploadedIcon = false;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _descriptionController.text = widget.service!.description;
      _iconUrlController.text = widget.service!.iconUrl;
      _toolsController.text = widget.service!.tools.join(', ');
      _orderController.text = widget.service!.order.toString();
      _isActive = widget.service!.isActive;

      // Determine if the existing service uses uploaded image or URL
      _useUploadedIcon = widget.service!.iconUrl.startsWith('http') &&
                        !widget.service!.iconUrl.startsWith('assets/');
    } else {
      // For new services, get the next order value
      _initializeOrderForNewService();
    }
  }

  Future<void> _initializeOrderForNewService() async {
    if (widget.isFirestoreEnabled) {
      try {
        final nextOrder = await ServiceService.getNextOrderValue();
        _orderController.text = nextOrder.toString();
      } catch (e) {
        _orderController.text = '0';
      }
    } else {
      _orderController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _iconUrlController.dispose();
    _toolsController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.service != null;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Service' : 'Add New Service',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Service Name *',
                          hintText: 'e.g., Web Development',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Service name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description *',
                          hintText: 'Describe what this service offers...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Icon Section
                      Text(
                        'Service Icon *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Icon Upload/URL Toggle
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Upload Image'),
                              value: true,
                              groupValue: _useUploadedIcon,
                              onChanged: (value) {
                                setState(() {
                                  _useUploadedIcon = value ?? true;
                                });
                              },
                              dense: true,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Use URL'),
                              value: false,
                              groupValue: _useUploadedIcon,
                              onChanged: (value) {
                                setState(() {
                                  _useUploadedIcon = value ?? false;
                                });
                              },
                              dense: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (_useUploadedIcon) ...[
                        // Image Upload Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              if (_selectedIconBytes != null || (widget.service != null && _useUploadedIcon)) ...[
                                // Image Preview
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _selectedIconBytes != null
                                        ? Image.memory(
                                            _selectedIconBytes!,
                                            fit: BoxFit.cover,
                                          )
                                        : (widget.service != null && widget.service!.iconUrl.isNotEmpty)
                                            ? Image.network(
                                                widget.service!.iconUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Icon(
                                                  Icons.broken_image,
                                                  size: 40,
                                                  color: Colors.grey.shade400,
                                                ),
                                              )
                                            : Icon(
                                                Icons.image,
                                                size: 40,
                                                color: Colors.grey.shade400,
                                              ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedIconBytes != null
                                      ? (_selectedIconFileName ?? 'Selected Image')
                                      : 'Current Image',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton.icon(
                                      onPressed: _pickIcon,
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Change'),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _selectedIconBytes = null;
                                          _selectedIconFileName = null;
                                        });
                                      },
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      label: const Text('Remove', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                // Upload Button
                                Column(
                                  children: [
                                    Icon(
                                      Icons.cloud_upload,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Click to upload icon',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: _pickIcon,
                                      icon: const Icon(Icons.upload),
                                      label: const Text('Choose File'),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ] else ...[
                        // URL Input
                        TextFormField(
                          controller: _iconUrlController,
                          decoration: InputDecoration(
                            labelText: 'Icon URL',
                            hintText: 'https://example.com/icon.svg or assets/icons/icon.svg',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (!_useUploadedIcon && (value == null || value.trim().isEmpty)) {
                              return 'Icon URL is required';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Tools/Technologies
                      TextFormField(
                        controller: _toolsController,
                        decoration: InputDecoration(
                          labelText: 'Tools/Technologies *',
                          hintText: 'Flutter, React, Node.js (comma separated)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'At least one tool/technology is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Display Order
                      TextFormField(
                        controller: _orderController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Display Order',
                          hintText: 'Lower numbers appear first (0, 1, 2...)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          helperText: 'Controls the order services appear on your portfolio',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Display order is required';
                          }
                          final order = int.tryParse(value.trim());
                          if (order == null || order < 0) {
                            return 'Please enter a valid number (0 or greater)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Active Status
                      Row(
                        children: [
                          Checkbox(
                            value: _isActive,
                            onChanged: (value) {
                              setState(() {
                                _isActive = value ?? true;
                              });
                            },
                          ),
                          const Text('Active (visible to users)'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(isEditing ? 'Update Service' : 'Add Service'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickIcon() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          setState(() {
            _selectedIconBytes = file.bytes;
            _selectedIconFileName = file.name;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation for image upload
    if (_useUploadedIcon && _selectedIconBytes == null && widget.service == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload an icon or switch to URL mode'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse tools from comma-separated string
      final tools = _toolsController.text
          .split(',')
          .map((tool) => tool.trim())
          .where((tool) => tool.isNotEmpty)
          .toList();

      String iconUrl;

      // Handle image upload if using uploaded icon
      if (_useUploadedIcon) {
        if (_selectedIconBytes != null && _selectedIconFileName != null) {
          // New image uploaded
          if (widget.isFirestoreEnabled) {
            // Generate a unique service ID for new services
            final serviceId = widget.service?.id ?? 'service_${DateTime.now().millisecondsSinceEpoch}';

            // Upload icon to Firebase Storage
            iconUrl = await StorageService.uploadServiceIcon(
              serviceId: serviceId,
              fileName: _selectedIconFileName!,
              fileBytes: _selectedIconBytes!,
            );
          } else {
            iconUrl = 'Selected: ${_selectedIconFileName}';
          }
        } else {
          // No new image uploaded, keep existing image URL
          iconUrl = widget.service?.iconUrl ?? '';
        }
      } else {
        // Using URL mode
        iconUrl = _iconUrlController.text.trim();
      }

      // Parse order
      final order = int.tryParse(_orderController.text.trim()) ?? 0;

      final serviceData = ServiceModel(
        id: widget.service?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        iconUrl: iconUrl,
        tools: tools,
        createdAt: widget.service?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: _isActive,
        order: order,
      );

      if (widget.isFirestoreEnabled) {
        // Check Firebase connection
        try {
          final connectionTest = await FirebaseService.testConnection();
          if (!connectionTest) {
            throw Exception('Firebase connection test failed');
          }
        } catch (networkError) {
          throw Exception('Firebase connection failed. Please check your internet connection.');
        }

        // Save to Firestore
        if (widget.service == null) {
          await ServiceService.addService(serviceData);
        } else {
          await ServiceService.updateService(widget.service!.id!, serviceData);
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.service == null 
                ? 'Service added successfully!' 
                : 'Service updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
