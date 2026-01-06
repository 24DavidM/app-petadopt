import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/refugio_repository.dart';

class ApproveRequestUseCase {
  final RefugioRepository repository;

  ApproveRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String requestId) async {
    return await repository.approveRequest(requestId);
  }
}
