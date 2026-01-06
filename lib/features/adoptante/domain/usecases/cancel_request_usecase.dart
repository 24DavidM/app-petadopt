import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/adoptante_repository.dart';

class CancelRequestUseCase {
  final AdoptanteRepository repository;

  CancelRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String requestId) async {
    return await repository.cancelRequest(requestId);
  }
}
