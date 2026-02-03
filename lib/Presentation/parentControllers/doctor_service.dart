// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class DoctorService {
  final DoctorUseCases useCase = initController(
    () => DoctorUseCases(Get.find()),
  );

  Future<void> addDoctorData({
    required DoctorModel doctor,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.addDoctor(doctor);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> updateDoctorData({
    required DoctorModel doctor,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.updateDoctor(doctor);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

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

  Future<void> getDoctorsData({
    required Map<String, dynamic> data,
    required SQLiteQueryParams query,
    bool? isFiltered,
    required Function(List<DoctorModel?>) voidCallBack,
  }) async {
    // Loader.show();
    final result = await useCase.getDoctors(data, query, isFiltered);
    result.fold(
      (l) => Loader.showError("Something went wrong"),
      (r) => voidCallBack(r),
    );
  }
}
