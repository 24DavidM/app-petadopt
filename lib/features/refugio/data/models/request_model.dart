import '../../domain/entities/request_entity.dart';

class RequestModel extends RequestEntity {
  const RequestModel({
    required super.id,
    required super.animalId,
    required super.adopterId,
    required super.shelterId,
    required super.status,
    super.notes,
    super.adopterName,
    super.adopterEmail,
    super.adopterPhone,
    super.animalName,
    super.animalSpecies,
    super.animalImageUrls,
    super.createdAt,
    super.updatedAt,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    // Manejo de datos anidados
    final adopterData = json['user_profiles'] as Map<String, dynamic>?;
    final animalData = json['animals'] as Map<String, dynamic>?;

    return RequestModel(
      id: json['id'] as String,
      animalId: json['animal_id'] as String,
      adopterId: json['adopter_id'] as String,
      shelterId: json['shelter_id'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      adopterName: adopterData?['full_name'] as String?,
      adopterEmail: adopterData?['email'] as String?,
      adopterPhone: adopterData?['phone'] as String?,
      animalName: animalData?['name'] as String?,
      animalSpecies: animalData?['species'] as String?,
      animalImageUrls: animalData?['image_urls'] != null
          ? List<String>.from(animalData!['image_urls'] as List)
          : null,
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
      'animal_id': animalId,
      'adopter_id': adopterId,
      'shelter_id': shelterId,
      'status': status,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  RequestEntity toEntity() => this;
}
