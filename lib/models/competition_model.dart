
import 'package:flutter_application_tubes/firebase_service.dart';
import 'package:flutter_application_tubes/Admin/dashboardAdmin.dart';
import 'package:flutter_application_tubes/Competition/competitionAcademic.dart';


// models/competition_model.dart
class Competition {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final String price;
  final List<String> prizes;
  final List<String> requirements;
  final String category; // 'academic' or 'non-academic'
  final DateTime registrationDeadline;
  final String location;
  final String teamSize;
  final String eligibility;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Competition({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.prizes,
    required this.requirements,
    required this.category,
    required this.registrationDeadline,
    required this.location,
    required this.teamSize,
    required this.eligibility,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'price': price,
      'prizes': prizes,
      'requirements': requirements,
      'category': category,
      'registrationDeadline': registrationDeadline.toIso8601String(),
      'location': location,
      'teamSize': teamSize,
      'eligibility': eligibility,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Map (Firebase)
  factory Competition.fromMap(Map<String, dynamic> map) {
    return Competition(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? '',
      prizes: List<String>.from(map['prizes'] ?? []),
      requirements: List<String>.from(map['requirements'] ?? []),
      category: map['category'] ?? '',
      registrationDeadline: DateTime.parse(map['registrationDeadline']),
      location: map['location'] ?? '',
      teamSize: map['teamSize'] ?? '',
      eligibility: map['eligibility'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Copy with method for updates
  Competition copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? description,
    String? price,
    List<String>? prizes,
    List<String>? requirements,
    String? category,
    DateTime? registrationDeadline,
    String? location,
    String? teamSize,
    String? eligibility,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Competition(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      price: price ?? this.price,
      prizes: prizes ?? this.prizes,
      requirements: requirements ?? this.requirements,
      category: category ?? this.category,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      location: location ?? this.location,
      teamSize: teamSize ?? this.teamSize,
      eligibility: eligibility ?? this.eligibility,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}