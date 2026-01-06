import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/refugio_repository.dart';

class UpdateShelterLocationUseCase {
  final RefugioRepository repository;

  UpdateShelterLocationUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    return await repository.updateShelterLocation(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }
}
