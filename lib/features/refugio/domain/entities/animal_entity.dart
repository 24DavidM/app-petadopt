import 'package:equatable/equatable.dart';

class AnimalEntity extends Equatable {
  final String id;
  final String name;
  final String species;
  final String? breed;
  final String? age;
  final String? gender;
  final String? size;
  final String? description;
  final String? notes;
  final List<String>? personality;
  final List<String>? healthStatus;
  final List<String>? imageUrls;
  final String status;
  final String shelterId;
  final int? viewsCount;
  final int? likesCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AnimalEntity({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.age,
    this.gender,
    this.size,
    this.description,
    this.notes,
    this.personality,
    this.healthStatus,
    this.imageUrls,
    required this.status,
    required this.shelterId,
    this.viewsCount,
    this.likesCount,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    species,
    breed,
    age,
    gender,
    size,
    description,
    notes,
    personality,
    healthStatus,
    imageUrls,
    status,
    shelterId,
    viewsCount,
    likesCount,
    createdAt,
    updatedAt,
  ];
}
