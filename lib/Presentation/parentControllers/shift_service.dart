// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class ShiftService {
  final ShiftUseCases useCase =
  initController(() => ShiftUseCases(Get.find()));

  // =========================================================
  // 🔹 ADD SHIFT
  // =========================================================
  Future<void> addShiftData({
    required ShiftModel shift,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final result = await useCase.addShift(shift);

    Loader.dismiss();

    result.fold(
          (l) {
        Loader.showError(l.messege ?? "حدث خطأ أثناء إضافة الفترة");
        voidCallBack(ResponseStatus.error);
      },
          (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // =========================================================
  // 🔹 UPDATE SHIFT
  // =========================================================
  Future<void> updateShiftData({
    required ShiftModel shift,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final result = await useCase.updateShift(shift);

    Loader.dismiss();

    result.fold(
          (l) {
        Loader.showError(l.messege ?? "فشل تحديث الفترة");
        voidCallBack(ResponseStatus.error);
      },
          (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // =========================================================
  // 🔹 DELETE SHIFT
  // =========================================================
  Future<void> deleteShiftData({
    required String shiftKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final result = await useCase.deleteShift(shiftKey);

    Loader.dismiss();

    result.fold(
          (l) {
        Loader.showError(l.messege ?? "فشل حذف الفترة");
        voidCallBack(ResponseStatus.error);
      },
          (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // =========================================================
  // 🔹 GET SHIFTS
  // =========================================================
  Future<void> getShiftsData({
    required FirebaseFilter data,
    required SQLiteQueryParams query,
    bool? isFiltered,
    bool? fromOnline, // 🔥 جديد
    required Function(List<ShiftModel?>) voidCallBack,
  }) async {
    final result = await useCase.getShifts(
      data,
      query,
      isFiltered,
      fromOnline: fromOnline,
    );

    result.fold(
          (l) {
        print("❌ [ShiftService] ${l.messege}");
        Loader.showError("حدث خطأ أثناء تحميل الفترات");
      },
          (r) {
        print("✅ [ShiftService] Loaded ${r.length} shifts");
        voidCallBack(r);
      },
    );
  }

  // =========================================================
  // 🔹 GET SHIFTS FROM PATIENT
  // =========================================================
  Future<void> getShiftssFromPatientData({
    required Map<String, dynamic> data,
    required String doctorKey,
    required Function(List<ShiftModel?>) voidCallBack,
  }) async {
    try {
      Loader.show();

      final result = await useCase.getShiftssFromPatient(
        data,
        doctorKey,
      );

      Loader.dismiss();

      result.fold(
            (l) {
          print("❌ [ShiftService] ${l.messege}");
          Loader.showError("حدث خطأ أثناء جلب بيانات الفترات");
        },
            (r) {
          print("✅ [ShiftService] Patient shifts: ${r.length}");
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