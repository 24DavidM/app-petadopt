import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class UpdateRoleUseCase {
  final AuthRepository repository;

  UpdateRoleUseCase(this.repository);

  Future<Either<Failure, void>> call(String role) async {
    return await repository.updateUserRole(role);
  }
}
