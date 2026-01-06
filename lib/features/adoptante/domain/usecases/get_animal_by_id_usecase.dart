import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/animal_entity.dart';
import '../repositories/adoptante_repository.dart';

class GetAnimalByIdUseCase {
  final AdoptanteRepository repository;

  GetAnimalByIdUseCase(this.repository);

  Future<Either<Failure, AnimalEntity>> call(String id) async {
    return await repository.getAnimalById(id);
  }
}
