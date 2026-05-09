// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class MedicalRecordPropertyService {
  final MedicalRecordPropertyUseCases useCase = initController(
    () => MedicalRecordPropertyUseCases(Get.find()),
  );

  /// ➕ Add Property
  Future<void> addMedicalRecordPropertyData({
    required MedicalRecordPropertyModel property,

    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final result = await useCase.addMedicalRecordProperty(property);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),

      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// 🔄 Update Property
  Future<void> updateMedicalRecordPropertyData({
    required MedicalRecordPropertyModel property,

    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final result = await useCase.updateMedicalRecordProperty(property);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),

      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// 🗑 Delete Property
  Future<void> deleteMedicalRecordPropertyData({
    required String propertyKey,

    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final result = await useCase.deleteMedicalRecordProperty(propertyKey);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),

      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// 🔍 Get All Properties
  Future<void> getMedicalRecordPropertiesData({
    required Map<String, dynamic> data,

    required SQLiteQueryParams query,

    required FirebaseFilter firebaseFilter,

    bool? isFiltered,

    required Function(List<MedicalRecordPropertyModel?>) voidCallBack,
  }) async {
    final result = await useCase.getMedicalRecordProperties(
      firebaseFilter.toJson(),
      query,
      isFiltered,
    );

    result.fold(
      (l) => Loader.showError("Something went wrong"),

      (r) => voidCallBack(r),
    );
  }
}
