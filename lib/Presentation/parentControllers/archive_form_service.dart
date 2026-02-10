// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class ArchiveFormService {
  final ArchiveFormUseCases useCase = initController(
    () => ArchiveFormUseCases(Get.find()),
  );

  /// 📄 Create new archive form
  Future<void> createArchiveFormData({
    required ArchiveFormModel form,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.createForm(form);
    Loader.dismiss();

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// ✏️ Update existing archive form
  Future<void> updateArchiveFormData({
    required String formId,
    required ArchiveFormModel form,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.updateForm(formId, form);
    Loader.dismiss();

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// 🗑 Delete archive form
  Future<void> deleteArchiveFormData({
    required String formId,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.deleteForm(formId);
    Loader.dismiss();

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// 📋 Get all archive forms
  Future<void> getArchiveFormsData({
    required Map<String, dynamic> data,
    required Function(List<ArchiveFormModel>) voidCallBack,
  }) async {
    final result = await useCase.getForms(data);
    result.fold(
      (l) => Loader.showError("Something went wrong"),
      (r) => voidCallBack(r),
    );
  }

  /// 📌 Get single archive form
  Future<void> getArchiveFormData({
    required String formId,
    required Function(ArchiveFormModel) voidCallBack,
  }) async {
    try {
      Loader.show();
      final result = await useCase.getForm(formId);
      Loader.dismiss();

      result.fold(
        (l) {
          print("❌ [ArchiveFormService] Error fetching form: ${l.messege}");
          Loader.showError("حدث خطأ أثناء جلب الفورم");
        },
        (r) {
          print("✅ [ArchiveFormService] Form fetched successfully");
          voidCallBack(r);
        },
      );
    } catch (e) {
      Loader.showError("حدث خطأ غير متوقع أثناء تحميل البيانات");
      print("❌ [ArchiveFormService] Exception: $e");
    }
  }
}
