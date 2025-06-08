import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysite/core/models/project_model.dart';
import 'package:mysite/core/services/project_service.dart';
import 'package:mysite/core/providers/data_provider.dart';
import 'package:mysite/core/configs/configs.dart';
import 'package:mysite/app/sections/admin/widgets/project_form_dialog.dart';
import 'package:sizer/sizer.dart';

class AdminProjectsView extends StatefulWidget {
  const AdminProjectsView({Key? key}) : super(key: key);

  @override
  State<AdminProjectsView> createState() => _AdminProjectsViewState();
}

class _AdminProjectsViewState extends State<AdminProjectsView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      body: Padding(
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
                      'Projects Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                      ),
                    ),
                    Text(
                      dataProvider.useFirestore
                          ? 'Connected to Firestore'
                          : 'Using static data (Firestore not configured)',
                      style: TextStyle(
                        fontSize: 12,
                        color: dataProvider.useFirestore
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddProjectDialog(context, dataProvider.useFirestore),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Project'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            Space.y(4.w)!,
            Expanded(
              child: dataProvider.useFirestore
                  ? StreamBuilder<List<ProjectModel>>(
                      stream: ProjectService.getAllProjects(),
                      builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  
                  final projects = snapshot.data ?? [];
                  
                  if (projects.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_off,
                            size: 64,
                            color: theme.textColor.withOpacity(0.5),
                          ),
                          Space.y(2.w)!,
                          Text(
                            'No projects found',
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.textColor.withOpacity(0.7),
                            ),
                          ),
                          Space.y(1.w)!,
                          Text(
                            'Add your first project to get started',
                            style: TextStyle(
                              color: theme.textColor.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ReorderableListView.builder(
                    itemCount: projects.length,
                    onReorder: (oldIndex, newIndex) => _onReorder(projects, oldIndex, newIndex),
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return Card(
                        key: ValueKey(project.id),
                        margin: EdgeInsets.only(bottom: 2.w),
                        child: ListTile(
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: project.isActive ? Colors.green : Colors.red,
                                width: 2,
                              ),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: project.bannerUrl.isNotEmpty
                                      ? (project.bannerUrl.startsWith('http')
                                          ? Image.network(
                                              project.bannerUrl,
                                              width: 56,
                                              height: 56,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                width: 56,
                                                height: 56,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.image_not_supported, size: 20),
                                              ),
                                            )
                                          : Image.asset(
                                              project.bannerUrl,
                                              width: 56,
                                              height: 56,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                width: 56,
                                                height: 56,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.image_not_supported, size: 20),
                                              ),
                                            ))
                                      : Container(
                                          width: 56,
                                          height: 56,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image, size: 20),
                                        ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: project.isActive ? Colors.green : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      project.isActive ? Icons.check : Icons.close,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          title: Text(
                            project.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.textColor,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.textColor.withOpacity(0.7),
                                ),
                              ),
                              Space.y(1.w)!,
                              Text(
                                'Updated: ${project.updatedAt.toString().split(' ')[0]}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textColor.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      _showEditProjectDialog(context, project, true);
                                      break;
                                    case 'toggle':
                                      _toggleProjectStatus(project);
                                      break;
                                    case 'delete':
                                      _showDeleteConfirmation(context, project);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'toggle',
                                    child: Row(
                                      children: [
                                        Icon(project.isActive
                                            ? Icons.visibility_off
                                            : Icons.visibility),
                                        const SizedBox(width: 8),
                                        Text(project.isActive ? 'Hide' : 'Show'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.drag_handle, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              )
              : _buildStaticProjectsList(context, dataProvider.staticProjects),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticProjectsList(BuildContext context, List<ProjectModel> projects) {
    final theme = Theme.of(context);

    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off,
              size: 64,
              color: theme.textColor.withValues(alpha: 0.5),
            ),
            Space.y(2.w)!,
            Text(
              'No projects found',
              style: TextStyle(
                fontSize: 18,
                color: theme.textColor.withValues(alpha: 0.7),
              ),
            ),
            Space.y(1.w)!,
            Text(
              'Configure Firestore to add projects',
              style: TextStyle(
                color: theme.textColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          margin: EdgeInsets.only(bottom: 2.w),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: const Icon(Icons.work, color: Colors.white),
            ),
            title: Text(
              project.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textColor.withValues(alpha: 0.7),
                  ),
                ),
                Space.y(1.w)!,
                Text(
                  'Static data - Configure Firestore to edit',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showFirestoreRequiredDialog(context),
            ),
          ),
        );
      },
    );
  }

  void _showFirestoreRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Firestore Required'),
        content: const Text(
          'To add, edit, or delete projects, you need to configure Firebase Firestore.\n\n'
          'Please follow the setup guide in FIREBASE_SETUP.md to:\n'
          '1. Get your Firebase configuration\n'
          '2. Update lib/firebase_options.dart\n'
          '3. Enable Authentication and Firestore in Firebase Console',
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

  void _showAddProjectDialog(BuildContext context, bool isFirestoreEnabled) {
    showDialog(
      context: context,
      builder: (context) => ProjectFormDialog(
        isFirestoreEnabled: isFirestoreEnabled,
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context, ProjectModel project, bool isFirestoreEnabled) {
    showDialog(
      context: context,
      builder: (context) => ProjectFormDialog(
        project: project,
        isFirestoreEnabled: isFirestoreEnabled,
      ),
    );
  }



  void _toggleProjectStatus(ProjectModel project) async {
    try {
      if (project.isActive) {
        await ProjectService.deleteProject(project.id!);
      } else {
        await ProjectService.restoreProject(project.id!);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(project.isActive 
                ? 'Project hidden successfully' 
                : 'Project restored successfully'),
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
    }
  }

  void _onReorder(List<ProjectModel> projects, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Create a copy of the list to avoid modifying the original
    final reorderedProjects = List<ProjectModel>.from(projects);
    final item = reorderedProjects.removeAt(oldIndex);
    reorderedProjects.insert(newIndex, item);

    try {
      // Update the order in Firestore
      await ProjectService.updateProjectOrders(reorderedProjects);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project order updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating project order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to permanently delete "${project.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ProjectService.permanentlyDeleteProject(project.id!);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Project deleted permanently'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
