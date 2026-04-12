import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class SyncService {
  /// ➕ Add Sync
  Future<void> addSyncData({
    required SyncModel sync,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    // Loader.show();
    //
    // final AddSyncUseCase addSyncUseCase = initController(
    //   () => AddSyncUseCase(Get.find()),
    // );
    //
    // final Either<AppError, SuccessModel> result = await addSyncUseCase.call(
    //   sync,
    // );
    //
    // result.fold(
    //   (l) => Loader.showError(l.messege),
    //   (r) => voidCallBack(ResponseStatus.success),
    // );

    Loader.dismiss();
  }

  /// ✏️ Update Sync
  Future<void> updateSyncData({
    required SyncModel sync,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    // final UpdateSyncUseCase updateSyncUseCase = initController(
    //   () => UpdateSyncUseCase(Get.find()),
    // );
    //
    // final Either<AppError, SuccessModel> result = await updateSyncUseCase.call(
    //   sync,
    // );
    //
    // result.fold(
    //   (l) => Loader.showError(l.messege),
    //   (r) => voidCallBack(ResponseStatus.success),
    // );

    Loader.dismiss();
  }

  /// ❌ Delete Sync
  Future<void> deleteSyncData({
    required String key,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    // final DeleteSyncUseCase deleteSyncUseCase = initController(
    //   () => DeleteSyncUseCase(Get.find()),
    // );
    //
    // final Either<AppError, SuccessModel> result = await deleteSyncUseCase.call(
    //   key,
    // );
    //
    // result.fold(
    //   (l) => Loader.showError(l.messege),
    //   (r) => voidCallBack(ResponseStatus.success),
    // );

    Loader.dismiss();
  }

  /// 🔍 Get a Single Sync
  Future<void> getSyncData({
    required bool is_online,
    required Function(SyncModel?) voidCallBack,
  }) async {
    // Loader.show(); // Optional depending on use case

    // final ReadSyncItemUseCase readSyncItemUseCase = initController(
    //   () => ReadSyncItemUseCase(Get.find()),
    // );
    //
    // final Either<AppError, SyncModel> result = await readSyncItemUseCase.call(
    //   is_online,
    // );
    //
    // result.fold((l) => Loader.showError(l.messege), (r) {
    //   voidCallBack(r);
    //   Loader.dismiss();
    // });
  }
}
