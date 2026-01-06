import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/location_entity.dart';
import '../repositories/mapa_repository.dart';

class GetCurrentLocationUseCase {
  final MapaRepository repository;

  GetCurrentLocationUseCase(this.repository);

  Future<Either<Failure, LocationEntity>> call() async {
    return await repository.getCurrentLocation();
  }
}
