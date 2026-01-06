import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/shelter_entity.dart';
import '../repositories/mapa_repository.dart';

class GetShelterByIdUseCase {
  final MapaRepository repository;

  GetShelterByIdUseCase(this.repository);

  Future<Either<Failure, ShelterEntity>> call(String id) async {
    return await repository.getShelterById(id);
  }
}
