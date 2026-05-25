import 'package:diwanclinic/Presentation/parentControllers/visite_parent_demo.dart';

import '../../../../../index/index_main.dart';

class CreateVisitModel extends GetxController {
  /// Existing visit (for update)
  VisitModel? existingVisit;

  bool isUpdate = false;

  /// =========================
  /// Controllers
  /// =========================

  final TextEditingController nameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  /// =========================
  /// INIT
  /// =========================

  @override
  Future<void> onInit() async {
    super.onInit();
  }

  /// =========================
  /// POPULATE
  /// =========================

  void populateFields(VisitModel visit) {
    nameController.text = visit.name ?? "";

    phoneController.text = visit.phone ?? "";

    addressController.text = visit.address ?? "";

    isUpdate = true;

    update();
  }

  /// =========================
  /// SAVE
  /// =========================

  void saveVisit() {
    final visit =
        existingVisit?.copyWith(
          name: nameController.text,
          phone: phoneController.text,
          address: addressController.text,
        ) ??
        VisitModel(
          key: const Uuid().v4(),

          name: nameController.text,

          phone: phoneController.text,

          address: addressController.text,
        );

    isUpdate ? updateVisit(visit) : createVisit(visit);
  }

  /// =========================
  /// CREATE
  /// =========================

  void createVisit(VisitModel visit) {
    VisitParentService().addVisit(
      visit: visit,

      callBack: (_) {
        Loader.showSuccess("تم الإنشاء بنجاح");

        Get.back();
      },
    );
  }

  /// =========================
  /// UPDATE
  /// =========================

  void updateVisit(VisitModel visit) {
    VisitParentService().updateVisit(
      visit: visit,

      callBack: (_) {
        Loader.showSuccess("تم التحديث بنجاح");

        Get.back();
      },
    );
  }

  /// =========================
  /// VALIDATION
  /// =========================

  bool validateStep() {
    return nameController.text.isNotEmpty;
  }

  /// =========================
  /// DISPOSE
  /// =========================

  @override
  void dispose() {
    nameController.dispose();

    phoneController.dispose();

    addressController.dispose();

    super.dispose();
  }
}
