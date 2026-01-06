import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/animal_entity.dart';
import '../entities/adoption_request_entity.dart';

abstract class AdoptanteRepository {
  Future<Either<Failure, List<AnimalEntity>>> getAnimals();

  Future<Either<Failure, List<AnimalEntity>>> getAnimalsBySpecies(
    String species,
  );

  Future<Either<Failure, AnimalEntity>> getAnimalById(String id);

  Future<Either<Failure, void>> createAdoptionRequest({
    required String animalId,
    required String notes,
  });

  Future<Either<Failure, List<AdoptionRequestEntity>>> getMyRequests();

  Future<Either<Failure, void>> cancelRequest(String requestId);

  Future<Either<Failure, bool>> isFavorite(String animalId);

  Future<Either<Failure, void>> toggleFavorite(String animalId);
}
