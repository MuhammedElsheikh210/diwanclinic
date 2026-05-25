import 'package:dartz/dartz.dart';
import 'package:diwanclinic/Domain/Repositories/base_repository.dart';

import '../../../index/index_main.dart';

class BaseUseCases<T> {
  final BaseRepository<T> repository;

  BaseUseCases(this.repository);

  /// =========================
  /// ADD
  /// =========================
  Future<Either<AppError, SuccessModel>> addItem(
      T item,
      Map<String, dynamic> Function(T item) toJson,
      String id,
      ) {
    return repository.addDomain(
      toJson(item),
      id,
    );
  }

  /// =========================
  /// UPDATE
  /// =========================
  Future<Either<AppError, SuccessModel>> updateItem(
      T item,
      Map<String, dynamic> Function(T item) toJson,
      String id,
      ) {
    return repository.updateDomain(
      toJson(item),
      id,
    );
  }

  /// =========================
  /// DELETE
  /// =========================
  Future<Either<AppError, SuccessModel>> deleteItem(
      String id,
      ) {
    return repository.deleteDomain(
      {},
      id,
    );
  }

  /// =========================
  /// GET ALL
  /// =========================
  Future<Either<AppError, List<T?>>> getItems(
      Map<String, dynamic> data,
      ) {
    return repository.getAllDomain(data);
  }
}