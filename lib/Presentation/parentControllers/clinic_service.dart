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

  Future<void> getClinicsFromPatientData({
    required Map<String, dynamic> data,
    required String doctorKey,
    required Function(List<ClinicModel>) voidCallBack, // 🔥 non-nullable
  }) async {
    try {
      Loader.show();

      final safeDoctorKey = doctorKey.trim().replaceAll("/", "");

      final result = await useCase.getClinicsFromPatient(data, safeDoctorKey);

      result.fold(
            (l) {
          Loader.dismiss();

          print(
            "❌ [ClinicService] Error fetching clinics for doctor: ${l.messege}",
          );

          Loader.showError("حدث خطأ أثناء جلب العيادات");

          voidCallBack([]); // ✅ always return safe empty list
        },
            (r) {
          Loader.dismiss();

          // 🔥 أهم سطر
          final safeList = r.whereType<ClinicModel>().toList();

          print(
            "✅ [ClinicService] Clinics fetched for doctor: ${safeList.length}",
          );

          voidCallBack(safeList);
        },
      );
    } catch (e) {
      Loader.dismiss(); // 🔥 مهم جدًا

      

      Loader.showError("حدث خطأ غير متوقع أثناء تحميل البيانات");

      voidCallBack([]); // ✅ fallback
    }
  }
}
