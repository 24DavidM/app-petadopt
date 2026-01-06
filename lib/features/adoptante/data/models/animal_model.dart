import '../../domain/entities/animal_entity.dart';

class AnimalModel extends AnimalEntity {
  const AnimalModel({
    required super.id,
    required super.name,
    required super.species,
    super.breed,
    super.age,
    super.gender,
    super.size,
    super.description,
    super.personality,
    super.healthStatus,
    super.notes,
    super.imageUrls,
    required super.status,
    required super.shelterId,
    super.shelterName,
    super.distance,
    super.viewsCount,
    super.likesCount,
    super.createdAt,
    super.updatedAt,
  });

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      age: json['age'] as String?,
      gender: json['gender'] as String?,
      size: json['size'] as String?,
      description: json['description'] as String?,
      personality: json['personality'] != null
          ? List<String>.from(json['personality'] as List)
          : null,
      healthStatus: json['health_status'] != null
          ? List<String>.from(json['health_status'] as List)
          : null,
      notes: json['notes'] as String?,
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'] as List)
          : null,
      status: json['status'] as String? ?? 'available',
      shelterId: json['shelter_id'] as String,
      shelterName: json['shelter_name'] as String?,
      distance: json['distance'] as String?,
      viewsCount: json['views_count'] as int?,
      likesCount: json['likes_count'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'gender': gender,
      'size': size,
      'description': description,
      'personality': personality,
      'health_status': healthStatus,
      'notes': notes,
      'image_urls': imageUrls,
      'status': status,
      'shelter_id': shelterId,
      'shelter_name': shelterName,
      'distance': distance,
      'views_count': viewsCount,
      'likes_count': likesCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  AnimalEntity toEntity() => this;
}
