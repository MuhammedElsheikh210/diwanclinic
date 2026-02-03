import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class SyncRepository {

  /// 🔄 Get individual sync model by key
  Future<Either<AppError, SyncModel>> getSyncSingle(Map<String, dynamic> data,bool? online);

  /// ➕ Add a new sync entry
  Future<Either<AppError, SuccessModel>> addSync(
    Map<String, dynamic> data,
    String key,
  );

  /// ✏️ Update an existing sync entry
  Future<Either<AppError, SuccessModel>> updateSync(
    Map<String, dynamic> data,
    String key,
  );

  /// ❌ Delete a sync entry
  Future<Either<AppError, SuccessModel>> deleteSync(
    Map<String, dynamic> data,
    String key,
  );
}
