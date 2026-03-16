import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class MedicalCenterService {
  /// ➕ Add Medical Center
  Future<void> addMedicalCenterData({
    required MedicalCenterModel center,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    MedicalCenterUseCases useCases = initController(
      () => MedicalCenterUseCases(Get.find()),
    );

    final Either<AppError, SuccessModel> result = await useCases
        .addMedicalCenter(center);

    result.fold(
      (l) => Loader.showError(l.messege),
      (r) => voidCallBack(ResponseStatus.success),
    );

    Loader.dismiss();
  }

  /// 🔄 Update Medical Center
  Future<void> updateMedicalCenterData({
    required MedicalCenterModel center,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    MedicalCenterUseCases useCases = initController(
      () => MedicalCenterUseCases(Get.find()),
    );

    final Either<AppError, SuccessModel> result = await useCases
        .updateMedicalCenter(center);

    result.fold(
      (l) => Loader.showError(l.messege),
      (r) => voidCallBack(ResponseStatus.success),
    );

    Loader.dismiss();
  }

  /// 🗑 Delete Medical Center
  Future<void> deleteMedicalCenterData({
    required String key,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    MedicalCenterUseCases useCases = initController(
      () => MedicalCenterUseCases(Get.find()),
    );

    final Either<AppError, SuccessModel> result = await useCases
        .deleteMedicalCenter(key);

    result.fold(
      (l) => Loader.showError(l.messege),
      (r) => voidCallBack(ResponseStatus.success),
    );

    Loader.dismiss();
  }

  /// 🔍 Get All Medical Centers
  Future<void> getAllMedicalCentersData({
    required Function(List<MedicalCenterModel?>) voidCallBack,
  }) async {
    MedicalCenterUseCases useCases = initController(
      () => MedicalCenterUseCases(Get.find()),
    );

    final Either<AppError, List<MedicalCenterModel?>> result = await useCases
        .getMedicalCenters({});

    result.fold((l) => Loader.showError(l.messege), (r) {
      voidCallBack(r);
      Loader.dismiss();
    });
  }

  /// 📌 Get Single Medical Center
  Future<void> getMedicalCenterData({
    required Map<String, dynamic> query,
    required Function(MedicalCenterModel?) voidCallBack,
  }) async {
    MedicalCenterUseCases useCases = initController(
      () => MedicalCenterUseCases(Get.find()),
    );

    final Either<AppError, MedicalCenterModel> result = await useCases
        .getMedicalCenter(query);

    result.fold((l) => Loader.showError(l.messege), (r) {
      voidCallBack(r);
      Loader.dismiss();
    });
  }
}
