import '../../domain/entities/adoption_request_entity.dart';

class AdoptionRequestModel extends AdoptionRequestEntity {
  const AdoptionRequestModel({
    required super.id,
    required super.animalId,
    required super.adopterId,
    required super.shelterId,
    required super.status,
    super.notes,
    super.animalName,
    super.shelterName,
    super.animalSpecies,
    super.animalImageUrls,
    super.createdAt,
    super.updatedAt,
  });

  factory AdoptionRequestModel.fromJson(Map<String, dynamic> json) {
    // Manejo de datos anidados del animal: Supabase puede devolver
    // la relación como una lista (even for single) o como un mapa.
    final dynamic animalsField = json['animals'];
    Map<String, dynamic>? animalData;
    if (animalsField is List && animalsField.isNotEmpty) {
      animalData = animalsField.first as Map<String, dynamic>?;
    } else if (animalsField is Map<String, dynamic>) {
      animalData = animalsField;
    } else {
      animalData = null;
    }

    // Extraer image_urls de forma segura
    List<String>? imageUrls;
    if (animalData != null && animalData['image_urls'] != null) {
      final images = animalData['image_urls'];
      if (images is List) {
        imageUrls = List<String>.from(images);
      } else if (images is String) {
        imageUrls = [images];
      }
    }

    // Handle shelter data - puede venir del campo 'shelter' o directamente en 'shelter_name'
    String? shelterName;

    // Primero intenta obtener del campo shelter (si existe un JOIN)
    final dynamic shelterField = json['shelter'];
    if (shelterField is Map<String, dynamic>) {
      shelterName = shelterField['full_name'] as String?;
    }

    // Si no, intenta obtener del campo directo shelter_name (agregado después de la query)
    if (shelterName == null && json['shelter_name'] != null) {
      shelterName = json['shelter_name'] as String?;
    }
    // shelterName puede ser null, la UI mostrará "Refugio" como fallback

    return AdoptionRequestModel(
      id: json['id'] as String,
      animalId: json['animal_id'] as String,
      adopterId: json['adopter_id'] as String,
      shelterId: json['shelter_id'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      animalName: animalData?['name'] as String?,
      shelterName: shelterName,
      animalSpecies: animalData?['species'] as String?,
      animalImageUrls: imageUrls,
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

  AdoptionRequestEntity toEntity() => this;
}
