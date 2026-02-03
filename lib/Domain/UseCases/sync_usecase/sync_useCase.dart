// ignore_for_file: avoid_renaming_method_parameters

import 'package:dartz/dartz.dart';
import 'package:diwanclinic/Data/Models/User_local/save_local_user.dart';
import '../../../index/index_main.dart';

/// ➕ Use case for adding a sync item.
class AddSyncUseCase
    extends Use_Case<Either<AppError, SuccessModel>, SyncModel> {
  final SyncRepository _repository;

  AddSyncUseCase(this._repository);

  @override
  Future<Either<AppError, SuccessModel>> call(SyncModel sync) async {
    return await _repository.addSync(
      sync.toJson(),
      LocalUser().getUserData().uid ?? "",
    );
  }
}

/// ❌ Use case for deleting a sync item.
class DeleteSyncUseCase
    extends Use_Case<Either<AppError, SuccessModel>, String> {
  final SyncRepository _repository;

  DeleteSyncUseCase(this._repository);

  @override
  Future<Either<AppError, SuccessModel>> call(String key) async {
    return await _repository.deleteSync({}, key);
  }
}

/// 📥 Use case for reading a single sync item.
class ReadSyncItemUseCase
    extends Use_Case<Either<AppError, SyncModel>, bool> {
  final SyncRepository _repository;

  ReadSyncItemUseCase(this._repository);

  @override
  Future<Either<AppError, SyncModel>> call(bool isOnline) async {
    return await _repository.getSyncSingle({},isOnline);
  }
}

/// ✏️ Use case for updating a sync item.
class UpdateSyncUseCase
    extends Use_Case<Either<AppError, SuccessModel>, SyncModel> {
  final SyncRepository _repository;

  UpdateSyncUseCase(this._repository);

  @override
  Future<Either<AppError, SuccessModel>> call(SyncModel sync) async {
    return await _repository.updateSync(
      sync.toJson(),
      LocalUser().getUserData().uid ?? "",
    );
  }
}
