import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../repositories/adoptante_repository.dart';

class IsFavoriteUseCase {
  final AdoptanteRepository repository;

  IsFavoriteUseCase(this.repository);

  Future<Either<Failure, bool>> call(String animalId) async {
    return await repository.isFavorite(animalId);
  }
}
