import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/request_entity.dart';
import '../repositories/refugio_repository.dart';

class GetRequestsUseCase {
  final RefugioRepository repository;

  GetRequestsUseCase(this.repository);

  Future<Either<Failure, List<RequestEntity>>> call() async {
    return await repository.getRequests();
  }
}
