import '../../domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({required super.latitude, required super.longitude});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}
