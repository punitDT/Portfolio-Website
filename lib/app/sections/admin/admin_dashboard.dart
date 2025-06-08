import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysite/core/providers/auth_provider.dart';
import 'package:mysite/core/providers/data_provider.dart';
import 'package:mysite/core/res/responsive.dart';
import 'package:mysite/core/configs/configs.dart';
import 'package:mysite/app/sections/admin/admin_projects.dart';
import 'package:mysite/app/sections/admin/admin_services.dart';
import 'package:mysite/core/services/firebase_service.dart';
import 'package:mysite/core/services/content_service.dart';
import 'package:sizer/sizer.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  List<AdminMenuItem> get _menuItems => [
    AdminMenuItem(
      icon: Icons.dashboard,
      title: 'Dashboard',
      widget: AdminOverview(
        onNavigate: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    ),
    AdminMenuItem(
      icon: Icons.work,
      title: 'Projects',
      widget: const AdminProjectsView(),
    ),
    AdminMenuItem(
      icon: Icons.build,
      title: 'Services',
      widget: const AdminServicesView(),
    ),
    AdminMenuItem(
      icon: Icons.edit,
      title: 'Content',
      widget: const AdminContentView(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/admin/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
            tooltip: 'View Portfolio',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Responsive.isDesktop(context)
          ? Row(
              children: [
                _buildSidebar(theme),
                Expanded(
                  child: _menuItems[_selectedIndex].widget,
                ),
              ],
            )
          : Column(
              children: [
                _buildMobileNavigation(theme),
                Expanded(
                  child: _menuItems[_selectedIndex].widget,
                ),
              ],
            ),
    );
  }

  Widget _buildSidebar(ThemeData theme) {
    return Container(
      width: 250,
      color: theme.cardColor,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: theme.primaryColor,
                  size: 30,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Admin Panel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = _selectedIndex == index;
                
                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: theme.primaryColor.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNavigation(ThemeData theme) {
    return Container(
      height: 60,
      color: theme.cardColor,
      child: Row(
        children: _menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = _selectedIndex == index;
          
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? theme.primaryColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AdminMenuItem {
  final IconData icon;
  final String title;
  final Widget widget;

  AdminMenuItem({
    required this.icon,
    required this.title,
    required this.widget,
  });
}

// Admin Overview Dashboard
class AdminOverview extends StatefulWidget {
  final Function(int)? onNavigate;

  const AdminOverview({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<AdminOverview> createState() => _AdminOverviewState();
}

class _AdminOverviewState extends State<AdminOverview> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.isDesktop(context) ? 4.w : 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, Admin!',
            style: TextStyle(
              fontSize: Responsive.isDesktop(context) ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Space.y(2.w)!,
          Text(
            'Manage your portfolio content from this dashboard',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Space.y(4.w)!,

          // Stats Cards
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildStatCard(
                context,
                'Projects',
                '8',
                Icons.work,
                Colors.blue,
                onTap: () => widget.onNavigate?.call(1), // Navigate to projects tab
              ),
              _buildStatCard(
                context,
                'Services',
                '6',
                Icons.build,
                Colors.green,
                onTap: () => widget.onNavigate?.call(2), // Navigate to services tab
              ),
              _buildStatCard(
                context,
                'Content Items',
                '12',
                Icons.article,
                Colors.orange,
                onTap: () => widget.onNavigate?.call(3), // Navigate to content tab
              ),
              _buildStatCard(
                context,
                'Last Updated',
                'Today',
                Icons.schedule,
                Colors.purple,
              ),
            ],
          ),

          Space.y(4.w)!,

          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Space.y(2.w)!,

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildActionButton(
                context,
                'Add Project',
                Icons.add_circle,
                () {
                  widget.onNavigate?.call(1); // Navigate to projects tab
                },
              ),
              _buildActionButton(
                context,
                'Edit Content',
                Icons.edit,
                () {
                  widget.onNavigate?.call(3); // Navigate to content tab
                },
              ),
              _buildActionButton(
                context,
                'View Site',
                Icons.launch,
                () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
              ),
              _buildActionButton(
                context,
                'Firebase Status',
                Icons.cloud,
                () {
                  _showFirebaseStatus(context);
                },
              ),
              _buildActionButton(
                context,
                'Initialize Content',
                Icons.refresh,
                () {
                  _initializeDefaultContent(context);
                },
              ),
              _buildActionButton(
                context,
                'Logout',
                Icons.logout,
                () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: Responsive.isDesktop(context) ? 200 : 150,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFirebaseStatus(BuildContext context) async {
    // Show loading dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Checking Firebase status...'),
          ],
        ),
      ),
    );

    try {
      final status = await FirebaseService.getFirebaseStatus();

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Firebase Status'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusSection('Authentication', status['auth']),
                  const SizedBox(height: 16),
                  _buildStatusSection('Firestore', status['firestore']),
                  const SizedBox(height: 16),
                  _buildStatusSection('Storage', status['storage']),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _testFirebaseConnection(context);
                },
                child: const Text('Test Connection'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Firebase Status Error'),
            content: Text('Failed to get Firebase status: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildStatusSection(String title, dynamic statusData) {
    final isError = statusData is Map && statusData.containsKey('error');
    final color = isError ? Colors.red : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            statusData.toString(),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _testFirebaseConnection(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Testing Firebase connection...'),
          ],
        ),
      ),
    );

    try {
      final success = await FirebaseService.testConnection();

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
              ? 'Firebase connection test successful!'
              : 'Firebase connection test failed!'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection test error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _initializeDefaultContent(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Initializing default content...'),
          ],
        ),
      ),
    );

    try {
      await ContentService.initializeDefaultContent();

      // Refresh the data provider
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      await dataProvider.refreshContent();

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Default content initialized successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize content: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// AdminProjectsView is now imported from admin_projects.dart



class AdminContentView extends StatefulWidget {
  const AdminContentView({Key? key}) : super(key: key);

  @override
  State<AdminContentView> createState() => _AdminContentViewState();
}

class _AdminContentViewState extends State<AdminContentView> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isEditing = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataProvider = Provider.of<DataProvider>(context);

    // Initialize or update controllers for all content entries
    for (final entry in dataProvider.content.entries) {
      if (!_controllers.containsKey(entry.key)) {
        _controllers[entry.key] = TextEditingController(text: entry.value);
      } else {
        // Update existing controller if value changed and not editing
        if (!_isEditing && _controllers[entry.key]!.text != entry.value) {
          _controllers[entry.key]!.text = entry.value;
        }
      }
    }

    // Remove controllers for content that no longer exists
    final keysToRemove = _controllers.keys.where((key) => !dataProvider.content.containsKey(key)).toList();
    for (final key in keysToRemove) {
      _controllers[key]?.dispose();
      _controllers.remove(key);
    }

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Content Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    dataProvider.useFirestore ? 'Connected to Firestore' : 'Using static data',
                    style: TextStyle(
                      fontSize: 14,
                      color: dataProvider.useFirestore ? Colors.blue : Colors.orange,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (_isEditing) ...[
                    ElevatedButton.icon(
                      onPressed: _saveContent,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _cancelEdit,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ] else
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _isEditing = true),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Content'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
          Space.y(4.w)!,
          Expanded(
            child: dataProvider.content.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        Space.y(2.w)!,
                        Text(
                          'No content found',
                          style: TextStyle(
                            fontSize: 18,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: dataProvider.content.length,
                    itemBuilder: (context, index) {
                      final entry = dataProvider.content.entries.elementAt(index);
                      final controller = _controllers[entry.key];

                      // Skip if controller doesn't exist (shouldn't happen but safety check)
                      if (controller == null) return const SizedBox.shrink();

                      return Card(
                        margin: EdgeInsets.only(bottom: 2.w),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatKey(entry.key),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _isEditing
                                  ? TextField(
                                      controller: controller,
                                      maxLines: null,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        hintText: 'Enter content...',
                                        filled: true,
                                        fillColor: theme.cardTheme.color ?? theme.colorScheme.surface,
                                      ),
                                      style: TextStyle(color: theme.colorScheme.onSurface),
                                    )
                                  : Text(
                                      entry.value,
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _saveContent() async {
    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      // Save all content changes to Firestore
      for (final entry in _controllers.entries) {
        final key = entry.key;
        final value = entry.value.text.trim();

        if (value.isNotEmpty) {
          await ContentService.updateContent(key, value);
        }
      }

      // Refresh the data provider to show updated content
      await dataProvider.refreshContent();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Content saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save content: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelEdit() {
    // Reset controllers to original values
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    for (final entry in dataProvider.content.entries) {
      _controllers[entry.key]?.text = entry.value;
    }
    setState(() => _isEditing = false);
  }
}
