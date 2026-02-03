// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class TransferService {
  final TransferUseCases useCase = initController(
        () => TransferUseCases(Get.find()),
  );

  Future<void> addTransferData({
    required TransferModel transfer,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.addTransfer(transfer);
    result.fold(
          (l) => voidCallBack(ResponseStatus.error),
          (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> updateTransferData({
    required TransferModel transfer,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.updateTransfer(transfer);
    result.fold(
          (l) => voidCallBack(ResponseStatus.error),
          (r) => voidCallBack(ResponseStatus.success),
    );
    Loader.dismiss();
  }

  Future<void> deleteTransferData({
    required String transferKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.deleteTransfer(transferKey);
    result.fold(
          (l) => voidCallBack(ResponseStatus.error),
          (r) => voidCallBack(ResponseStatus.success),
    );
    Loader.dismiss();
  }

  Future<void> getTransfersData({
    required Map<String, dynamic> data,
    required SQLiteQueryParams query,
    bool? isFiltered,
    required Function(List<TransferModel?>) voidCallBack,
  }) async {
  //  Loader.show();
    final result = await useCase.getTransfers(data, query, isFiltered);
    result.fold(
          (l) => Loader.showError("Something went wrong"),
          (r) => voidCallBack(r),
    );
  }
}
