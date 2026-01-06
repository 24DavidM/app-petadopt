import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/shelter_entity.dart';
import '../repositories/mapa_repository.dart';

class GetNearbySheltersUseCase {
  final MapaRepository repository;

  GetNearbySheltersUseCase(this.repository);

  Future<Either<Failure, List<ShelterEntity>>> call({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
  }) async {
    return await repository.getNearbyShelters(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }
}
