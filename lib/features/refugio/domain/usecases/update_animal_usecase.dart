import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/refugio_repository.dart';

class UpdateAnimalUseCase {
  final RefugioRepository repository;

  UpdateAnimalUseCase(this.repository);

  Future<Either<Failure, void>> call({
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
    return await repository.updateAnimal(
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
      newImages: newImages,
      existingImageUrls: existingImageUrls,
    );
  }
}
