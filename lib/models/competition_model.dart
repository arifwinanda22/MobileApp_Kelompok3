// models/competition.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_tubes/Admin/dashboardAdmin.dart';

class Competition {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String prize;
  final String imageUrl;
  final DateTime deadline;
  final String status;
  final int participants;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Competition({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.prize,
    required this.imageUrl,
    required this.deadline,
    required this.status,
    required this.participants,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory constructor untuk membuat Competition dari Map/JSON
  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'academic',
      prize: json['prize'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      deadline: json['deadline'] is Timestamp
          ? (json['deadline'] as Timestamp).toDate()
          : json['deadline'] is DateTime
              ? json['deadline']
              : DateTime.now().add(Duration(days: 30)),
      status: json['status'] ?? 'active',
      participants: json['participants'] ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : json['createdAt'] is DateTime
              ? json['createdAt']
              : DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : json['updatedAt'] is DateTime
              ? json['updatedAt']
              : null,
    );
  }

  // Factory constructor alternatif untuk fromMap
  factory Competition.fromMap(Map<String, dynamic> map) {
    return Competition.fromJson(map);
  }

  // Method untuk mengkonversi Competition ke Map/JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'prize': prize,
      'imageUrl': imageUrl,
      'deadline': deadline,
      'status': status,
      'participants': participants,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Method alternatif untuk toMap
  Map<String, dynamic> toMap() {
    return toJson();
  }

  // Method untuk mengkonversi ke Firestore (dengan Timestamp)
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'prize': prize,
      'imageUrl': imageUrl,
      'deadline': Timestamp.fromDate(deadline),
      'status': status,
      'participants': participants,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Method copyWith untuk membuat salinan dengan perubahan
  Competition copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? prize,
    String? imageUrl,
    DateTime? deadline,
    String? status,
    int? participants,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Competition(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      prize: prize ?? this.prize,
      imageUrl: imageUrl ?? this.imageUrl,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      participants: participants ?? this.participants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}