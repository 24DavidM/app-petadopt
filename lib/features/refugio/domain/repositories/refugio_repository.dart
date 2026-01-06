import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../entities/animal_entity.dart';
import '../entities/request_entity.dart';

abstract class RefugioRepository {
  /// Obtiene todos los animales del refugio
  Future<Either<Failure, List<AnimalEntity>>> getMyAnimals();

  /// Obtiene un animal por ID
  Future<Either<Failure, AnimalEntity>> getAnimalById(String id);

  /// Crea un nuevo animal
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
  });

  /// Actualiza un animal existente
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
  });

  /// Elimina un animal
  Future<Either<Failure, void>> deleteAnimal(String id);

  /// Verifica si un animal tiene solicitudes activas
  Future<Either<Failure, bool>> hasActiveRequests(String animalId);

  /// Obtiene todas las solicitudes de adopción
  Future<Either<Failure, List<RequestEntity>>> getRequests();

  /// Obtiene solicitudes por estado
  Future<Either<Failure, List<RequestEntity>>> getRequestsByStatus(
    String status,
  );

  /// Aprueba una solicitud
  Future<Either<Failure, void>> approveRequest(String requestId);

  /// Rechaza una solicitud
  Future<Either<Failure, void>> rejectRequest(String requestId);

  /// Actualiza la ubicación del refugio
  Future<Either<Failure, void>> updateShelterLocation({
    required double latitude,
    required double longitude,
    required String address,
  });
}
