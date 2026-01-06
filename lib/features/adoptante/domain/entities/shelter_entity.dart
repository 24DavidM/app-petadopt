import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class ShelterEntity extends Equatable {
  final String id;
  final String userId; 
  final String shelterName; 
  final LatLng location;
  final String address;
  
  final String? phone; 
  final String? email; 
  final String? avatarUrl; 
  final bool isActive; 
  final double? distance; 
  const ShelterEntity({
    required this.id,
    required this.userId,
    required this.shelterName,
    required this.location,
    required this.address,
    this.phone,
    this.email,
    this.avatarUrl,
    this.isActive = true,
    this.distance,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    shelterName,
    location,
    address,
    phone,
    email,
    avatarUrl,
    isActive,
    distance,
  ];
}
