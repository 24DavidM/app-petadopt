import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class RefugioEvent extends Equatable {
  const RefugioEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyAnimalsEvent extends RefugioEvent {}

class LoadRefugioDashboardEvent extends RefugioEvent {}

class LoadAnimalByIdEvent extends RefugioEvent {
  final String id;

  const LoadAnimalByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateAnimalEvent extends RefugioEvent {
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
  final List<XFile> images;

  const CreateAnimalEvent({
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
    required this.images,
  });

  @override
  List<Object?> get props => [
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
    images,
  ];
}

class UpdateAnimalEvent extends RefugioEvent {
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
  final List<XFile>? newImages;
  final List<String>? existingImageUrls;

  const UpdateAnimalEvent({
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
    this.newImages,
    this.existingImageUrls,
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
    newImages,
    existingImageUrls,
  ];
}

class DeleteAnimalEvent extends RefugioEvent {
  final String id;

  const DeleteAnimalEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CheckActiveRequestsEvent extends RefugioEvent {
  final String animalId;

  const CheckActiveRequestsEvent(this.animalId);

  @override
  List<Object?> get props => [animalId];
}

class LoadRequestsEvent extends RefugioEvent {}

class LoadRequestsByStatusEvent extends RefugioEvent {
  final String status;

  const LoadRequestsByStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class ApproveRequestEvent extends RefugioEvent {
  final String requestId;

  const ApproveRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class RejectRequestEvent extends RefugioEvent {
  final String requestId;

  const RejectRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class UpdateLocationEvent extends RefugioEvent {
  final double latitude;
  final double longitude;
  final String address;

  const UpdateLocationEvent({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  List<Object?> get props => [latitude, longitude, address];
}
