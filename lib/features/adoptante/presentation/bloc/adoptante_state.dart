import 'package:equatable/equatable.dart';
import '../../domain/entities/animal_entity.dart';
import '../../domain/entities/adoption_request_entity.dart';

abstract class AdoptanteState extends Equatable {
  const AdoptanteState();

  @override
  List<Object?> get props => [];
}

class AdoptanteInitial extends AdoptanteState {}

class AdoptanteLoading extends AdoptanteState {}

class AnimalsLoaded extends AdoptanteState {
  final List<AnimalEntity> animals;

  const AnimalsLoaded(this.animals);

  @override
  List<Object?> get props => [animals];
}

class AnimalLoaded extends AdoptanteState {
  final AnimalEntity animal;

  const AnimalLoaded(this.animal);

  @override
  List<Object?> get props => [animal];
}

class AdoptionRequestCreated extends AdoptanteState {}

class MyRequestsLoaded extends AdoptanteState {
  final List<AdoptionRequestEntity> requests;

  const MyRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class RequestCancelled extends AdoptanteState {}

class AdoptanteError extends AdoptanteState {
  final String message;

  const AdoptanteError(this.message);

  @override
  List<Object?> get props => [message];
}
