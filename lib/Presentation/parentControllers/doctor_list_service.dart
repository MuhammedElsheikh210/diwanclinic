// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class DoctorListService {
  final DoctorListUseCases useCase = initController(
    () => DoctorListUseCases(Get.find()),
  );

  /// ➕ Add Doctor
  Future<void> addDoctorData({
    required DoctorListModel doctor,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.addDoctor(doctor);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// 🔄 Update Doctor
  Future<void> updateDoctorData({
    required DoctorListModel doctor,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.updateDoctor(doctor);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// 🗑 Delete Doctor
  Future<void> deleteDoctorData({
    required String doctorKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.deleteDoctor(doctorKey);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// 🔍 Get Doctor List
  Future<void> getDoctorListData({
    required Map<String, dynamic> query,
    required Function(List<DoctorListModel>) voidCallBack,
  }) async {
    final result = await useCase.getDoctorList(query);

    result.fold(
      (l) => Loader.showError("Something went wrong"),
      (r) => voidCallBack(r),
    );
  }
}
