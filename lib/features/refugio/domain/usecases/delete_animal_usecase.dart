import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/refugio_repository.dart';

class DeleteAnimalUseCase {
  final RefugioRepository repository;

  DeleteAnimalUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteAnimal(id);
  }
}
