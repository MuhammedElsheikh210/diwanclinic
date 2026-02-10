import '../../../../../index/index_main.dart';

class CreateArchiveFormViewModel extends GetxController {
  ArchiveFormModel? currentForm;
  bool isUpdate = false;
  bool isLoading = true;

  /// 📥 تحميل الفورم (أول فورم بس)
  void loadFormFromServer() {
    isLoading = true;
    update();

    ArchiveFormService().getArchiveFormsData(
      data: {},
      voidCallBack: (forms) {
        if (forms.isNotEmpty) {
          currentForm = forms.first; // ✅ index 0
          isUpdate = true;
        } else {
          initEmptyForm();
        }
        isLoading = false;
        update();
      },
    );
  }

  void initEmptyForm() {
    currentForm = ArchiveFormModel(id: "", fields: []);
    isUpdate = false;
  }

  List<ArchiveFieldModel> get fields => currentForm?.fields ?? [];

  void addField(ArchiveFieldModel field) {
    currentForm!.fields.add(field);
    update();
  }

  void removeField(int index) {
    currentForm!.fields.removeAt(index);
    update();
  }

  bool validateForm() => fields.isNotEmpty;

  void saveForm() {
    final service = ArchiveFormService();

    if (isUpdate && currentForm!.id.isNotEmpty) {
      service.updateArchiveFormData(
        formId: currentForm!.id,
        form: currentForm!,
        voidCallBack: (_) => Get.back(),
      );
    } else {
      service.createArchiveFormData(
        form: currentForm!,
        voidCallBack: (_) => Get.back(),
      );
    }
  }
}
