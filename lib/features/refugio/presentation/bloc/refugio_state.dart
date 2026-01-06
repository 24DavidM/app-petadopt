import 'package:equatable/equatable.dart';
import '../../domain/entities/animal_entity.dart';
import '../../domain/entities/request_entity.dart';

abstract class RefugioState extends Equatable {
  const RefugioState();

  @override
  List<Object?> get props => [];
}

class RefugioInitial extends RefugioState {}

class RefugioLoading extends RefugioState {}

class RefugioDashboardLoaded extends RefugioState {
  final int totalAnimals;
  final int adoptedAnimals;
  final int pendingRequests;
  final List<RequestEntity> recentRequests;
  final List<AnimalEntity> recentAnimals;

  const RefugioDashboardLoaded({
    required this.totalAnimals,
    required this.adoptedAnimals,
    required this.pendingRequests,
    required this.recentRequests,
    this.recentAnimals = const [],
  });

  @override
  List<Object?> get props => [
    totalAnimals,
    adoptedAnimals,
    pendingRequests,
    recentRequests,
    recentAnimals,
  ];
}

class MyAnimalsLoaded extends RefugioState {
  final List<AnimalEntity> animals;

  const MyAnimalsLoaded(this.animals);

  @override
  List<Object?> get props => [animals];
}

class AnimalLoaded extends RefugioState {
  final AnimalEntity animal;

  const AnimalLoaded(this.animal);

  @override
  List<Object?> get props => [animal];
}

class AnimalCreated extends RefugioState {}

class AnimalUpdated extends RefugioState {}

class AnimalDeleted extends RefugioState {}

class ActiveRequestsChecked extends RefugioState {
  final bool hasActiveRequests;

  const ActiveRequestsChecked(this.hasActiveRequests);

  @override
  List<Object?> get props => [hasActiveRequests];
}

class RequestsLoaded extends RefugioState {
  final List<RequestEntity> requests;

  const RequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class RequestApproved extends RefugioState {}

class RequestRejected extends RefugioState {}

class LocationUpdated extends RefugioState {}

class RefugioError extends RefugioState {
  final String message;

  const RefugioError(this.message);

  @override
  List<Object?> get props => [message];
}
