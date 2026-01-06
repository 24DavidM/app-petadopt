import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/animal_entity.dart';
import '../../domain/entities/request_entity.dart';
import '../../domain/repositories/refugio_repository.dart';
import '../datasources/refugio_remote_data_source.dart';

class RefugioRepositoryImpl implements RefugioRepository {
  final RefugioRemoteDataSource remoteDataSource;

  RefugioRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AnimalEntity>>> getMyAnimals() async {
    try {
      final animals = await remoteDataSource.getMyAnimals();
      return Right(animals);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnimalEntity>> getAnimalById(String id) async {
    try {
      final animal = await remoteDataSource.getAnimalById(id);
      return Right(animal);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createAnimal({
    required String name,
    required String species,
    String? breed,
    String? age,
    String? gender,
    String? size,
    String? description,
    String? notes,
    List<String>? personality,
    List<String>? healthStatus,
    required List<XFile> images,
  }) async {
    try {
      // Subir imágenes primero
      final imageUrls = await remoteDataSource.uploadImages(images);

      // Crear animal con las URLs de las imágenes
      await remoteDataSource.createAnimal(
        name: name,
        species: species,
        breed: breed,
        age: age,
        gender: gender,
        size: size,
        description: description,
        notes: notes,
        personality: personality,
        healthStatus: healthStatus,
        imageUrls: imageUrls,
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAnimal({
    required String id,
    required String name,
    required String species,
    String? breed,
    String? age,
    String? gender,
    String? size,
    String? description,
    String? notes,
    List<String>? personality,
    List<String>? healthStatus,
    List<XFile>? newImages,
    List<String>? existingImageUrls,
  }) async {
    try {
      List<String> finalImageUrls = existingImageUrls ?? [];

      // Subir nuevas imágenes si existen
      if (newImages != null && newImages.isNotEmpty) {
        final newUrls = await remoteDataSource.uploadImages(newImages);
        finalImageUrls.addAll(newUrls);
      }

      // Actualizar animal
      await remoteDataSource.updateAnimal(
        id: id,
        name: name,
        species: species,
        breed: breed,
        age: age,
        gender: gender,
        size: size,
        description: description,
        notes: notes,
        personality: personality,
        healthStatus: healthStatus,
        imageUrls: finalImageUrls,
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAnimal(String id) async {
    try {
      await remoteDataSource.deleteAnimal(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasActiveRequests(String animalId) async {
    try {
      final result = await remoteDataSource.hasActiveRequests(animalId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RequestEntity>>> getRequests() async {
    try {
      final requests = await remoteDataSource.getRequests();
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RequestEntity>>> getRequestsByStatus(
    String status,
  ) async {
    try {
      final requests = await remoteDataSource.getRequestsByStatus(status);
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveRequest(String requestId) async {
    try {
      await remoteDataSource.approveRequest(requestId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectRequest(String requestId) async {
    try {
      await remoteDataSource.rejectRequest(requestId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateShelterLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    try {
      await remoteDataSource.updateShelterLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
