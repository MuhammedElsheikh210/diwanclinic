import '../../../../../index/index_main.dart';

class MedicalPropertyCreatsViewmodel extends GetxController {
  /// ✅ Dynamic category type
  final String? categoryType;

  /// ✅ Selected category
  final CategoryEntity? categoryEntity;

  MedicalPropertyCreatsViewmodel({this.categoryType, this.categoryEntity});

  /// ✅ Controllers
  final TextEditingController nameController = TextEditingController();

  /// ✅ text - number - date
  String? selectedType;

  bool is_update = false;

  MedicalRecordPropertyModel? existingProperty;

  @override
  Future<void> onInit() async {
    /// ✅ Reset old state
    existingProperty = null;

    is_update = false;

    selectedType = null;

    nameController.clear();

    super.onInit();
  }

  /// ✅ Populate fields
  void populateFields(MedicalRecordPropertyModel property) {
    nameController.text = property.label ?? "";

    selectedType = property.type;

    existingProperty = property;

    is_update = true;

    update();
  }

  /// ✅ Save Property
  void saveProperty() {
    if (selectedType == null || selectedType!.isEmpty) {
      Loader.showError("من فضلك اختر نوع القيمة");

      return;
    }

    final property =
        is_update && existingProperty != null
            ? existingProperty!.copyWith(
              label: nameController.text.trim(),

              type: selectedType,

              categoryKey: categoryEntity?.key,
            )
            : MedicalRecordPropertyModel(
              key: const Uuid().v4(),

              categoryKey: categoryEntity?.key,

              label: nameController.text.trim(),

              type: selectedType,
            );

    if (is_update) {
      updateProperty(property);
    } else {
      createProperty(property);
    }
  }

  /// ✅ Create Property
  void createProperty(MedicalRecordPropertyModel property) {
    MedicalRecordPropertyService().addMedicalRecordPropertyData(
      property: property,

      voidCallBack: (_) {
        refreshListView();

        Loader.showSuccess("تم إنشاء الخاصية بنجاح");
      },
    );
  }

  /// ✅ Update Property
  void updateProperty(MedicalRecordPropertyModel property) {
    MedicalRecordPropertyService().updateMedicalRecordPropertyData(
      property: property,

      voidCallBack: (_) {
        refreshListView();

        Loader.showSuccess("تم تحديث الخاصية بنجاح");
      },
    );
  }

  /// ✅ Refresh List
  void refreshListView() {
    final medicalPropertyViewModel = initController(
      () => MedicalPropertyViewModel(
        categoryType: categoryType,

        categoryEntity: categoryEntity,
      ),
    );

    medicalPropertyViewModel.getData();

    medicalPropertyViewModel.update();

    Get.back();
  }

  /// ✅ Validation
  bool validateStep() {
    return nameController.text.trim().isNotEmpty && selectedType != null;
  }

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }
}
