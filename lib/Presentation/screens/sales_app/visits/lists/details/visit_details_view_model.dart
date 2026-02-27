
import '../../../../../../index/index_main.dart';

class VisitDetailsViewModel extends GetxController {
  late VisitModel currentVisit;

  /// 🔹 Controllers للحقلـول اللي بتظهر conditionally
  final TextEditingController assistantNameController = TextEditingController();

  final TextEditingController assistantPhoneController =
      TextEditingController();

  final TextEditingController doctorWhatsappController =
      TextEditingController();

  /// 🔹 Init
  void init(VisitModel visit) {
    currentVisit = visit;

    /// Populate controllers بالقيم القديمة
    assistantNameController.text = visit.assistantName ?? "";

    assistantPhoneController.text = visit.assistantPrivatePhone ?? "";

    doctorWhatsappController.text = visit.doctorPrivateWhatsapp ?? "";
  }

  /// 🔹 Update Visit Status
  void updateVisitStatus(String status) {
    currentVisit = currentVisit.copyWith(visitStatus: status);
    update();
  }

  /// 🔹 Update Sales Status
  void updateSalesStatus(String status) {
    currentVisit = currentVisit.copyWith(doctorSalesStatus: status);
    update();
  }

  /// 🔹 Update Follow Up
  void updateFollowUp(DateTime dateTime) {
    currentVisit = currentVisit.copyWith(
      followUpTimestamp: dateTime.millisecondsSinceEpoch,
    );
    update();
  }

  /// 🔹 Update Steps
  void toggleStep1(bool value) {
    currentVisit = currentVisit.copyWith(step1TrainAssistantDemo: value);
    update();
  }

  void toggleStep2(bool value) {
    currentVisit = currentVisit.copyWith(step2DoctorPresentation: value);
    update();
  }

  void toggleStep3(bool value) {
    currentVisit = currentVisit.copyWith(step3TrainAssistant: value);
    update();
  }

  void toggleStep4(bool value) {
    currentVisit = currentVisit.copyWith(step4CreateAccount: value);
    update();
  }

  /// 🔥 Save Update
  void save() {
    /// ناخد القيم الحالية من الـ controllers
    final updated = currentVisit.copyWith(
      assistantName: assistantNameController.text.trim(),
      assistantPrivatePhone: assistantPhoneController.text.trim(),
      doctorPrivateWhatsapp: doctorWhatsappController.text.trim(),
    );

    VisitService().updateVisitData(
      visit: updated,
      voidCallBack: (_) {
        Loader.showSuccess("تم حفظ التعديلات بنجاح");
        VisitViewModel visitViewModel = initController(() => VisitViewModel());
        visitViewModel.getData();
        visitViewModel.update();
        Get.back();
      },
    );

    currentVisit = updated;
  }

  @override
  void onClose() {
    assistantNameController.dispose();
    assistantPhoneController.dispose();
    doctorWhatsappController.dispose();
    super.onClose();
  }


}
