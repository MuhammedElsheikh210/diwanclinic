import '../../../../../index/index_main.dart';

class CreateMedicalCenterViewModel extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = false;

  /// ➕ Create Medical Center
  Future<void> createMedicalCenter() async {
    if (!validate()) {
      Loader.showError("يرجى إدخال جميع البيانات");
      return;
    }

    final center = MedicalCenterModel(
      key: const Uuid().v4(),
      name: nameController.text.trim(),
      address: addressController.text.trim(),
      phone: phoneController.text.trim(),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      isDeleted: false,
    );

    MedicalCenterService().addMedicalCenterData(
      center: center,
      voidCallBack: (_) {
        Loader.showSuccess("تم إضافة المركز بنجاح");
        MedicalCenterViewModel medicalCenterViewModel = initController(
          () => MedicalCenterViewModel(),
        );
        medicalCenterViewModel.getData();
        Get.back();
      },
    );
  }

  bool validate() {
    return nameController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        phoneController.text.isNotEmpty;
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
