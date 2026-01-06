import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/shelter_entity.dart';
import '../../domain/repositories/mapa_repository.dart';
import '../datasources/location_data_source.dart';
import '../datasources/shelter_data_source.dart';

class MapaRepositoryImpl implements MapaRepository {
  final LocationDataSource locationDataSource;
  final ShelterDataSource shelterDataSource;

  MapaRepositoryImpl({
    required this.locationDataSource,
    required this.shelterDataSource,
  });

  @override
  Future<Either<Failure, LocationEntity>> getCurrentLocation() async {
    try {
      final location = await locationDataSource.getCurrentLocation();
      return Right(location);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ShelterEntity>>> getNearbyShelters({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
  }) async {
    try {
      final shelters = await shelterDataSource.getNearbyShelters(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      return Right(shelters);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ShelterEntity>> getShelterById(String id) async {
    try {
      final shelter = await shelterDataSource.getShelterById(id);
      return Right(shelter);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
