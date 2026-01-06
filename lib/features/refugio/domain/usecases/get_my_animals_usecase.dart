import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/animal_entity.dart';
import '../repositories/refugio_repository.dart';

class GetMyAnimalsUseCase {
  final RefugioRepository repository;

  GetMyAnimalsUseCase(this.repository);

  Future<Either<Failure, List<AnimalEntity>>> call() async {
    return await repository.getMyAnimals();
  }
}
