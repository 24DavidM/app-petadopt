import 'package:latlong2/latlong.dart';
import '../../domain/entities/shelter_entity.dart';

class ShelterModel extends ShelterEntity {
  const ShelterModel({
    required super.id,
    required super.userId,
    required super.shelterName,
    required super.location,
    required super.address,
    super.phone,
    super.email,
    super.avatarUrl,
    super.isActive = true,
    super.distance,
  });

  factory ShelterModel.fromJson(Map<String, dynamic> json) {
    return ShelterModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      shelterName: json['shelter_name'] as String,
      location: LatLng(json['latitude'] as double, json['longitude'] as double),
      address: json['address'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      distance: (json['distance_km'] as num?)?.toDouble(), // From RPC function
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'address': address,
      'is_active': isActive,
    };
  }
}
