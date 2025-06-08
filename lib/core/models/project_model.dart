import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String? id;
  final String title;
  final String description;
  final String? link;
  final String bannerUrl;
  final String iconUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int order;

  ProjectModel({
    this.id,
    required this.title,
    required this.description,
    this.link,
    required this.bannerUrl,
    required this.iconUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.order = 0,
  });

  // Convert from Firestore document
  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      link: data['link'],
      bannerUrl: data['bannerUrl'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'link': link,
      'bannerUrl': bannerUrl,
      'iconUrl': iconUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'order': order,
    };
  }

  // Create a copy with updated fields
  ProjectModel copyWith({
    String? id,
    String? title,
    String? description,
    String? link,
    String? bannerUrl,
    String? iconUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? order,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
    );
  }
}
