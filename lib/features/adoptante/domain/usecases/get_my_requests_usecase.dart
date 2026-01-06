import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/adoption_request_entity.dart';
import '../repositories/adoptante_repository.dart';

class GetMyRequestsUseCase {
  final AdoptanteRepository repository;

  GetMyRequestsUseCase(this.repository);

  Future<Either<Failure, List<AdoptionRequestEntity>>> call() async {
    return await repository.getMyRequests();
  }
}
