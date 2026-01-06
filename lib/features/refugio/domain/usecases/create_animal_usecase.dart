import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/refugio_repository.dart';

class CreateAnimalUseCase {
  final RefugioRepository repository;

  CreateAnimalUseCase(this.repository);

  Future<Either<Failure, void>> call({
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
    return await repository.createAnimal(
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
      images: images,
    );
  }
}
