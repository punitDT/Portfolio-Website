import 'package:cloud_firestore/cloud_firestore.dart';

class ContentModel {
  final String? id;
  final String key;
  final String value;
  final String type; // 'text', 'url', 'email', etc.
  final DateTime updatedAt;

  ContentModel({
    this.id,
    required this.key,
    required this.value,
    required this.type,
    required this.updatedAt,
  });

  // Convert from Firestore document
  factory ContentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContentModel(
      id: doc.id,
      key: data['key'] ?? '',
      value: data['value'] ?? '',
      type: data['type'] ?? 'text',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'key': key,
      'value': value,
      'type': type,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create a copy with updated fields
  ContentModel copyWith({
    String? id,
    String? key,
    String? value,
    String? type,
    DateTime? updatedAt,
  }) {
    return ContentModel(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
