import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/request_entity.dart';
import '../repositories/refugio_repository.dart';

class GetRequestsByStatusUseCase {
  final RefugioRepository repository;

  GetRequestsByStatusUseCase(this.repository);

  Future<Either<Failure, List<RequestEntity>>> call(String status) async {
    return await repository.getRequestsByStatus(status);
  }
}
