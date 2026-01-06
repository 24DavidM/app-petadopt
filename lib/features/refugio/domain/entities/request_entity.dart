import 'package:equatable/equatable.dart';

class RequestEntity extends Equatable {
  final String id;
  final String animalId;
  final String adopterId;
  final String shelterId;
  final String status; // 'pending', 'approved', 'rejected', 'cancelled'
  final String? notes;
  final String? adopterName;
  final String? adopterEmail;
  final String? adopterPhone;
  final String? animalName;
  final String? animalSpecies;
  final List<String>? animalImageUrls;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RequestEntity({
    required this.id,
    required this.animalId,
    required this.adopterId,
    required this.shelterId,
    required this.status,
    this.notes,
    this.adopterName,
    this.adopterEmail,
    this.adopterPhone,
    this.animalName,
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
    adopterName,
    adopterEmail,
    adopterPhone,
    animalName,
    animalSpecies,
    animalImageUrls,
    createdAt,
    updatedAt,
  ];
}
