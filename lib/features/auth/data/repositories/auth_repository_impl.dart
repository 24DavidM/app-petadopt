import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final user = await remoteDataSource.login(email, password);
      await localDataSource.cacheUser(user);
      return Right(user.toEntity());
    } on AppAuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error del servidor: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(
    String email,
    String password,
    String name,
    String role,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final user = await remoteDataSource.register(email, password, name, role);
      await localDataSource.cacheUser(user);
      return Right(user.toEntity());
    } on AppAuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error del servidor: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final user = await remoteDataSource.signInWithGoogle();
      await localDataSource.cacheUser(user);
      return Right(user.toEntity());
    } on AppAuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error del servidor: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserRole(String role) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      await remoteDataSource.updateUserRole(role);
      return const Right(null);
    } on AppAuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error del servidor: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCache();
      return const Right(null);
    } on AppAuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error del servidor: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      await remoteDataSource.resetPassword(email);
      return const Right(null);
    } on AppAuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error del servidor: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      if (user != null) {
        await localDataSource.cacheUser(user);
        return Right(user.toEntity());
      }

      // Si no hay usuario en Supabase, intentar obtenerlo del caché
      final cachedUser = await localDataSource.getCachedUser();
      return Right(cachedUser?.toEntity());
    } catch (e) {
      // En caso de error, intentar obtener del caché
      try {
        final cachedUser = await localDataSource.getCachedUser();
        return Right(cachedUser?.toEntity());
      } catch (e) {
        return Left(CacheFailure('Error al obtener usuario: $e'));
      }
    }
  }
}
