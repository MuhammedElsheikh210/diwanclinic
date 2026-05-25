import 'package:dartz/dartz.dart';
import 'package:diwanclinic/Domain/Repositories/base_repository.dart';

import '../../index/index_main.dart';

import '../data_source/base_crud_repo.dart';

class BaseRepositoryImpl<T> extends BaseRepository<T> {
  final BaseCrudRepo<T> repo;

  BaseRepositoryImpl(this.repo);

  /// =========================
  /// GET ALL
  /// =========================
  @override
  Future<Either<AppError, List<T?>>> getAllDomain(
      Map<String, dynamic> data,
      ) async {
    try {
      final result = await repo.getAll(data);

      return Right(result);
    } catch (e) {
      return Left(
        AppError(e.toString()),
      );
    }
  }

  /// =========================
  /// ADD
  /// =========================
  @override
  Future<Either<AppError, SuccessModel>> addDomain(
      Map<String, dynamic> data,
      String id,
      ) async {
    try {
      final result = await repo.add(
        data,
        id,
      );

      return Right(result);
    } catch (e) {
      return Left(
        AppError(e.toString()),
      );
    }
  }

  /// =========================
  /// DELETE
  /// =========================
  @override
  Future<Either<AppError, SuccessModel>> deleteDomain(
      Map<String, dynamic> data,
      String id,
      ) async {
    try {
      final result = await repo.delete(
        data,
        id,
      );

      return Right(result);
    } catch (e) {
      return Left(
        AppError(e.toString()),
      );
    }
  }

  /// =========================
  /// UPDATE
  /// =========================
  @override
  Future<Either<AppError, SuccessModel>> updateDomain(
      Map<String, dynamic> data,
      String id,
      ) async {
    try {
      final result = await repo.update(
        data,
        id,
      );

      return Right(result);
    } catch (e) {
      return Left(
        AppError(e.toString()),
      );
    }
  }
}