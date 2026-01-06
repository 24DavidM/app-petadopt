import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/adoptante_repository.dart';

class CreateAdoptionRequestUseCase {
  final AdoptanteRepository repository;

  CreateAdoptionRequestUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String animalId,
    required String notes,
  }) async {
    return await repository.createAdoptionRequest(
      animalId: animalId,
      notes: notes,
    );
  }
}
