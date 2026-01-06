import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/refugio_repository.dart';

class HasActiveRequestsUseCase {
  final RefugioRepository repository;

  HasActiveRequestsUseCase(this.repository);

  Future<Either<Failure, bool>> call(String animalId) async {
    return await repository.hasActiveRequests(animalId);
  }
}
