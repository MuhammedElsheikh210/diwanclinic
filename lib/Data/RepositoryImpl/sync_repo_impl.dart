// sync_repo_impl.dart
// ignore_for_file: non_constant_identifier_names

import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class SyncRepoImpl extends SyncRepository {
  final SyncDataSourceRepo _remoteDataSource;

  SyncRepoImpl(this._remoteDataSource);

  /// 🔄 Get a single Sync record
  @override
  Future<Either<AppError, SyncModel>> getSyncSingle(
    Map<String, dynamic> data,bool? online
  ) async {
    final result = await _remoteDataSource.getSync(data,online);

    if (result is Success<SyncModel?>) {
      final model = result.data;
      if (model != null) {
        return right(model);
      } else {
        return left(const AppError("Sync record not found"));
      }
    } else {
      return left(AppError((result as Failure).errorHandler.message ?? ""));
    }
  }

  /// ➕ Add a Sync record
  @override
  Future<Either<AppError, SuccessModel>> addSync(
    Map<String, dynamic> data,
    String key,
  ) async {
    final result = await _remoteDataSource.addSync(data, key);
    return result is Success<SuccessModel>
        ? right(result.data)
        : left(AppError((result as Failure).errorHandler.message ?? ""));
  }

  /// ✏️ Update a Sync record
  @override
  Future<Either<AppError, SuccessModel>> updateSync(
    Map<String, dynamic> data,
    String key,
  ) async {
    final result = await _remoteDataSource.updateSync(data, key);
    return result is Success<SuccessModel>
        ? right(result.data)
        : left(AppError((result as Failure).errorHandler.message ?? ""));
  }

  /// ❌ Delete a Sync record
  @override
  Future<Either<AppError, SuccessModel>> deleteSync(
    Map<String, dynamic> data,
    String key,
  ) async {
    final result = await _remoteDataSource.deleteSync(data, key);
    return result is Success<SuccessModel>
        ? right(result.data)
        : left(AppError((result as Failure).errorHandler.message ?? ""));
  }
}
