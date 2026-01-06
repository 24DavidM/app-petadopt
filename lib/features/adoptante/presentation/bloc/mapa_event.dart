import 'package:equatable/equatable.dart';

abstract class MapaEvent extends Equatable {
  const MapaEvent();

  @override
  List<Object?> get props => [];
}

class LoadCurrentLocationEvent extends MapaEvent {}

class LoadNearbySheltersEvent extends MapaEvent {
  final double latitude;
  final double longitude;
  final double radiusKm;

  const LoadNearbySheltersEvent({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 50.0,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusKm];
}
