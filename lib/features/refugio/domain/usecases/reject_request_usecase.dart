import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/refugio_repository.dart';

class RejectRequestUseCase {
  final RefugioRepository repository;

  RejectRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String requestId) async {
    return await repository.rejectRequest(requestId);
  }
}
