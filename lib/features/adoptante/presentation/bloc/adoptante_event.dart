import 'package:equatable/equatable.dart';

abstract class AdoptanteEvent extends Equatable {
  const AdoptanteEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnimalsEvent extends AdoptanteEvent {}

class LoadAnimalsBySpeciesEvent extends AdoptanteEvent {
  final String species;

  const LoadAnimalsBySpeciesEvent(this.species);

  @override
  List<Object?> get props => [species];
}

class LoadAnimalByIdEvent extends AdoptanteEvent {
  final String id;

  const LoadAnimalByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateAdoptionRequestEvent extends AdoptanteEvent {
  final String animalId;
  final String notes;

  const CreateAdoptionRequestEvent({
    required this.animalId,
    required this.notes,
  });

  @override
  List<Object?> get props => [animalId, notes];
}

class LoadMyRequestsEvent extends AdoptanteEvent {}

class CancelRequestEvent extends AdoptanteEvent {
  final String requestId;

  const CancelRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}
