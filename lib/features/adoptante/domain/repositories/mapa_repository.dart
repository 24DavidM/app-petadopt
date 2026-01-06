import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/location_entity.dart';
import '../entities/shelter_entity.dart';

abstract class MapaRepository {
  Future<Either<Failure, LocationEntity>> getCurrentLocation();
  Future<Either<Failure, List<ShelterEntity>>> getNearbyShelters({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
  });
  Future<Either<Failure, ShelterEntity>> getShelterById(String id);
}
