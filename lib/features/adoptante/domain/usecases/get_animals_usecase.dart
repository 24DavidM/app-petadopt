import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/animal_entity.dart';
import '../repositories/adoptante_repository.dart';

class GetAnimalsUseCase {
  final AdoptanteRepository repository;

  GetAnimalsUseCase(this.repository);

  Future<Either<Failure, List<AnimalEntity>>> call() async {
    return await repository.getAnimals();
  }
}
