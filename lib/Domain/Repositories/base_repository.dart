import 'package:dartz/dartz.dart';

import '../../index/index_main.dart';

abstract class BaseRepository<T> {
  /// 🔍 Get all items
  Future<Either<AppError, List<T?>>> getAllDomain(
      Map<String, dynamic> data,
      );

  /// ➕ Add item
  Future<Either<AppError, SuccessModel>> addDomain(
      Map<String, dynamic> data,
      String id,
      );

  /// 🗑 Delete item
  Future<Either<AppError, SuccessModel>> deleteDomain(
      Map<String, dynamic> data,
      String id,
      );

  /// 🔄 Update item
  Future<Either<AppError, SuccessModel>> updateDomain(
      Map<String, dynamic> data,
      String id,
      );
}