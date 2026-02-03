// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class ShiftService {
  final ShiftUseCases useCase = initController(() => ShiftUseCases(Get.find()));

  Future<void> addShiftData({
    required ShiftModel shift,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.addShift(shift);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> updateShiftData({
    required ShiftModel shift,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.updateShift(shift);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> deleteShiftData({
    required String shiftKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.deleteShift(shiftKey);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> getShiftsData({
    required FirebaseFilter data,
    required SQLiteQueryParams query,
    bool? isFiltered,
    required Function(List<ShiftModel?>) voidCallBack,
  }) async {
    final result = await useCase.getShifts(data, query, isFiltered);
    result.fold(
      (l) => Loader.showError("Something went wrong"),
      (r) => voidCallBack(r),
    );
  }

  /// 👩‍⚕️ Get shifts for a specific doctor (used by patient side)
  Future<void> getShiftssFromPatientData({
    required Map<String, dynamic> data,
    required String doctorKey,
    required Function(List<ShiftModel?>) voidCallBack,
  }) async {
    try {
      Loader.show();
      final result = await useCase.getShiftssFromPatient(data, doctorKey);
      Loader.dismiss();

      result.fold(
        (l) {
          print(
            "❌ [ShiftService] Error fetching shifts for doctor: ${l.messege}",
          );
          Loader.showError("حدث خطأ أثناء جلب بيانات الفترات");
        },
        (r) {
          print("✅ [ShiftService] Shifts fetched for doctor: ${r.length}");
          voidCallBack(r);
        },
      );
    } catch (e) {
      Loader.dismiss();
      Loader.showError("حدث خطأ غير متوقع أثناء تحميل بيانات الفترات");
      print("❌ [ShiftService] Exception: $e");
    }
  }
}
