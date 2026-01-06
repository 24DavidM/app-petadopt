import 'package:equatable/equatable.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/shelter_entity.dart';

abstract class MapaState extends Equatable {
  const MapaState();

  @override
  List<Object?> get props => [];
}

class MapaInitial extends MapaState {}

class MapaLoading extends MapaState {}

class LocationLoaded extends MapaState {
  final LocationEntity location;

  const LocationLoaded(this.location);

  @override
  List<Object?> get props => [location];
}

class SheltersLoaded extends MapaState {
  final LocationEntity userLocation;
  final List<ShelterEntity> shelters;

  const SheltersLoaded({required this.userLocation, required this.shelters});

  @override
  List<Object?> get props => [userLocation, shelters];
}

class MapaError extends MapaState {
  final String message;

  const MapaError(this.message);

  @override
  List<Object?> get props => [message];
}
