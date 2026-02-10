// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class ArchivePatientService {
  final ArchivePatientUseCases useCase = initController(
    () => ArchivePatientUseCases(Get.find()),
  );

  /// 📄 Create new archive patient
  Future<void> createArchivePatientData({
    required ArchivePatientModel archivePatient,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.createArchivePatient(archivePatient);
    Loader.dismiss();

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// ✏️ Update existing archive patient
  Future<void> updateArchivePatientData({
    required String archiveId,
    required ArchivePatientModel archivePatient,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.updateArchivePatient(
      archiveId,
      archivePatient,
    );
    Loader.dismiss();

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// 🗑 Delete archive patient
  Future<void> deleteArchivePatientData({
    required String archiveId,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.deleteArchivePatient(archiveId);
    Loader.dismiss();

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// 📋 Get all archive patients
  Future<void> getArchivePatientsData({
    required Map<String, dynamic> data,
    required Function(List<ArchivePatientModel>) voidCallBack,
  }) async {
    final result = await useCase.getArchivePatients(data);

    result.fold(
      (l) => Loader.showError("Something went wrong"),
      (r) => voidCallBack(r),
    );
  }

  /// 📌 Get single archive patient
  Future<void> getArchivePatientData({
    required String archiveId,
    required Function(ArchivePatientModel) voidCallBack,
  }) async {
    try {
      Loader.show();
      final result = await useCase.getArchivePatient(archiveId);
      Loader.dismiss();

      result.fold(
        (l) {
          print(
            "❌ [ArchivePatientService] Error fetching archive: ${l.messege}",
          );
          Loader.showError("حدث خطأ أثناء جلب أرشيف المريض");
        },
        (r) {
          print("✅ [ArchivePatientService] Archive fetched successfully");
          voidCallBack(r);
        },
      );
    } catch (e) {
      Loader.showError("حدث خطأ غير متوقع أثناء تحميل البيانات");
      print("❌ [ArchivePatientService] Exception: $e");
    }
  }
}
