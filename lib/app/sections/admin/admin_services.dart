import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:mysite/core/providers/data_provider.dart';
import 'package:mysite/core/models/service_model.dart';
import 'package:mysite/core/services/service_service.dart';
import 'package:mysite/core/configs/configs.dart';
import 'package:mysite/app/sections/admin/widgets/service_form_dialog.dart';
import 'package:sizer/sizer.dart';

class AdminServicesView extends StatefulWidget {
  const AdminServicesView({Key? key}) : super(key: key);

  @override
  State<AdminServicesView> createState() => _AdminServicesViewState();
}

class _AdminServicesViewState extends State<AdminServicesView> {
  Widget _buildServiceIcon(ServiceModel service) {
    final iconUrl = service.iconUrl;

    // Handle network URLs (from Firebase Storage or external URLs)
    if (iconUrl.startsWith('http')) {
      if (iconUrl.toLowerCase().endsWith('.svg')) {
        // For network SVG files, use fallback icon
        return const Icon(
          Icons.build,
          color: Colors.white,
          size: 20,
        );
      } else {
        // For network images (PNG, JPG, etc.)
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            iconUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.build,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      }
    }
    // Handle local asset files
    else if (iconUrl.startsWith('assets/')) {
      if (iconUrl.toLowerCase().endsWith('.svg')) {
        // For local SVG assets
        return SvgPicture.asset(
          iconUrl,
          width: 20,
          height: 20,
          color: Colors.white,
        );
      } else {
        // For local image assets
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            iconUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.build,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      }
    }
    // Fallback for any other cases
    else {
      return const Icon(
        Icons.build,
        color: Colors.white,
        size: 20,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataProvider = Provider.of<DataProvider>(context);

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
                    'Services Management',
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
                  if (dataProvider.useFirestore)
                    Text(
                      'Drag services to reorder • Lower numbers appear first',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showServiceDialog(context, null),
                icon: const Icon(Icons.add),
                label: const Text('Add Service'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          Space.y(4.w)!,
          Expanded(
            child: dataProvider.services.isEmpty
                ? _buildEmptyState(theme)
                : _buildServicesList(dataProvider.services, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.build_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          Space.y(2.w)!,
          Text(
            'No services found',
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Space.y(1.w)!,
          Text(
            'Add your first service to get started',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          Space.y(3.w)!,
          ElevatedButton.icon(
            onPressed: () => _showServiceDialog(context, null),
            icon: const Icon(Icons.add),
            label: const Text('Add Service'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(List<ServiceModel> services, ThemeData theme) {
    return ReorderableListView.builder(
      itemCount: services.length,
      onReorder: (oldIndex, newIndex) => _reorderServices(services, oldIndex, newIndex),
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          key: ValueKey(service.id),
          margin: EdgeInsets.only(bottom: 2.w),
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.drag_handle,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: service.isActive ? Colors.blue : Colors.grey,
                  child: _buildServiceIcon(service),
                ),
              ],
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${service.order}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    service.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (!service.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Inactive',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: service.tools.take(3).map((tool) => Chip(
                    label: Text(
                      tool,
                      style: const TextStyle(fontSize: 10),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleServiceAction(value, service),
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
                      Icon(service.isActive ? Icons.visibility_off : Icons.visibility),
                      const SizedBox(width: 8),
                      Text(service.isActive ? 'Deactivate' : 'Activate'),
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
          ),
        );
      },
    );
  }

  void _showServiceDialog(BuildContext context, ServiceModel? service) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => ServiceFormDialog(
        service: service,
        isFirestoreEnabled: dataProvider.useFirestore,
      ),
    ).then((result) {
      if (result == true) {
        // Refresh the services list
        dataProvider.refreshServices();
      }
    });
  }

  void _handleServiceAction(String action, ServiceModel service) {
    switch (action) {
      case 'edit':
        _showServiceDialog(context, service);
        break;
      case 'toggle':
        _toggleServiceStatus(service);
        break;
      case 'delete':
        _showDeleteConfirmation(service);
        break;
    }
  }

  void _toggleServiceStatus(ServiceModel service) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    
    try {
      if (dataProvider.useFirestore) {
        final updatedService = service.copyWith(
          isActive: !service.isActive,
          updatedAt: DateTime.now(),
        );
        await ServiceService.updateService(service.id!, updatedService);
        dataProvider.refreshServices();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(service.isActive 
              ? 'Service deactivated successfully!' 
              : 'Service activated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(ServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteService(service);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteService(ServiceModel service) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    try {
      if (dataProvider.useFirestore) {
        await ServiceService.permanentlyDeleteService(service.id!);
        dataProvider.refreshServices();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _reorderServices(List<ServiceModel> services, int oldIndex, int newIndex) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    if (!dataProvider.useFirestore) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reordering is only available with Firestore'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Adjust newIndex if moving down
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      // Create a copy of the list and reorder it
      final reorderedServices = List<ServiceModel>.from(services);
      final item = reorderedServices.removeAt(oldIndex);
      reorderedServices.insert(newIndex, item);

      // Update the order values
      final updatedServices = <ServiceModel>[];
      for (int i = 0; i < reorderedServices.length; i++) {
        updatedServices.add(reorderedServices[i].copyWith(order: i));
      }

      // Save the new order to Firestore
      await ServiceService.reorderServices(updatedServices);

      // Refresh the UI
      dataProvider.refreshServices();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Services reordered successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error reordering services: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
