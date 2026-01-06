import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/animal_entity.dart';
import '../../domain/entities/adoption_request_entity.dart';
import '../../domain/repositories/adoptante_repository.dart';
import '../datasources/adoptante_remote_data_source.dart';

class AdoptanteRepositoryImpl implements AdoptanteRepository {
  final AdoptanteRemoteDataSource remoteDataSource;

  AdoptanteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AnimalEntity>>> getAnimals() async {
    try {
      final animals = await remoteDataSource.getAnimals();
      return Right(animals.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AnimalEntity>>> getAnimalsBySpecies(
    String species,
  ) async {
    try {
      final animals = await remoteDataSource.getAnimalsBySpecies(species);
      return Right(animals.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnimalEntity>> getAnimalById(String id) async {
    try {
      final animal = await remoteDataSource.getAnimalById(id);
      return Right(animal.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createAdoptionRequest({
    required String animalId,
    required String notes,
  }) async {
    try {
      await remoteDataSource.createAdoptionRequest(
        animalId: animalId,
        notes: notes,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdoptionRequestEntity>>> getMyRequests() async {
    try {
      final requests = await remoteDataSource.getMyRequests();
      return Right(requests.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelRequest(String requestId) async {
    try {
      await remoteDataSource.cancelRequest(requestId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String animalId) async {
    try {
      final result = await remoteDataSource.isFavorite(animalId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(String animalId) async {
    try {
      await remoteDataSource.toggleFavorite(animalId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
