import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/animal_entity.dart';
import '../repositories/adoptante_repository.dart';

class GetAnimalsBySpeciesUseCase {
  final AdoptanteRepository repository;

  GetAnimalsBySpeciesUseCase(this.repository);

  Future<Either<Failure, List<AnimalEntity>>> call(String species) async {
    return await repository.getAnimalsBySpecies(species);
  }
}
