// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class MedicineService {
  final MedicineUseCases useCase = initController(
    () => MedicineUseCases(Get.find()),
  );

  Future<void> searchMedicinesData({
    required String keyword,
    required Function(List<MedicineModel>) voidCallBack,
  }) async {
    final result = await useCase.searchMedicines(keyword);

    result.fold(
      (l) => Loader.showError("Something went wrong"),
      (r) => voidCallBack(r),
    );
  }
}
