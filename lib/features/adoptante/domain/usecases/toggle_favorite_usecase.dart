import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../repositories/adoptante_repository.dart';

class ToggleFavoriteUseCase {
  final AdoptanteRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<Either<Failure, void>> call(String animalId) async {
    return await repository.toggleFavorite(animalId);
  }
}
