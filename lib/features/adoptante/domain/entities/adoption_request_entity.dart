import 'package:equatable/equatable.dart';

class AdoptionRequestEntity extends Equatable {
  final String id;
  final String animalId;
  final String adopterId;
  final String shelterId;
  final String status; // 'pending', 'approved', 'rejected'
  final String? notes;
  final String? animalName;
  final String? shelterName;
  final String? animalSpecies;
  final List<String>? animalImageUrls;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdoptionRequestEntity({
    required this.id,
    required this.animalId,
    required this.adopterId,
    required this.shelterId,
    required this.status,
    this.notes,
    this.animalName,
    this.shelterName,
    this.animalSpecies,
    this.animalImageUrls,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    animalId,
    adopterId,
    shelterId,
    status,
    notes,
    animalName,
    shelterName,
    animalSpecies,
    animalImageUrls,
    createdAt,
    updatedAt,
  ];
}
