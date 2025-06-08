import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String? id;
  final String name;
  final String description;
  final String iconUrl;
  final List<String> tools;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int order;

  ServiceModel({
    this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.tools,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.order = 0,
  });

  // Convert from Firestore document
  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      tools: List<String>.from(data['tools'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'tools': tools,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'order': order,
    };
  }

  // Create a copy with updated fields
  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    List<String>? tools,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? order,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      tools: tools ?? this.tools,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
    );
  }
}
