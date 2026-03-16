// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class ClinicService {
  final ClinicUseCases useCase = initController(
    () => ClinicUseCases(Get.find()),
  );

  Future<void> addClinicData({
    required ClinicModel clinic,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.addClinic(clinic);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> updateClinicData({
    required ClinicModel clinic,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.updateClinic(clinic);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> deleteClinicData({
    required String clinicKey,
    required String doctorKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final result = await useCase.deleteClinic(clinicKey, doctorKey);

    Loader.dismiss();

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// 🏥 Get all clinics (general list)
  Future<void> getClinicsData({
    required Map<String, dynamic> data,
    required SQLiteQueryParams query,
    required String doctorKey,

    required FirebaseFilter filrebaseFilter,
    bool? isFiltered,
    bool? fromOnline, //
    required Function(List<ClinicModel?>) voidCallBack,
  }) async {
    final result = await useCase.getClinics(
      filrebaseFilter.toJson(),
      query,
      doctorKey,
      isFiltered,
      fromOnline,
    );
    result.fold(
      (l) => Loader.showError("Something went wrong"),
      (r) => voidCallBack(r),
    );
  }

  /// 👩‍⚕️ Get clinics for a specific doctor (for patient view)
  Future<void> getClinicsFromPatientData({
    required Map<String, dynamic> data,
    required String doctorKey,
    required Function(List<ClinicModel?>) voidCallBack,
  }) async {
    try {
      Loader.show();
      final result = await useCase.getClinicsFromPatient(data, doctorKey);
      Loader.dismiss();
      result.fold(
        (l) {
          print(
            "❌ [ClinicService] Error fetching clinics for doctor: ${l.messege}",
          );
          Loader.showError("حدث خطأ أثناء جلب العيادات");
        },
        (r) {
          print("✅ [ClinicService] Clinics fetched for doctor: ${r.length}");
          voidCallBack(r);
        },
      );
    } catch (e) {
      Loader.showError("حدث خطأ غير متوقع أثناء تحميل البيانات");
      print("❌ [ClinicService] Exception: $e");
    }
  }
}
