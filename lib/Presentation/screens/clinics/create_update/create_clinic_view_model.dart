// ignore_for_file: avoid_renaming_method_parameters
import '../../../../../index/index_main.dart';

class CreateClinicViewModel extends GetxController {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phone1Controller = TextEditingController();
  final TextEditingController phone2Controller = TextEditingController();
  final TextEditingController emergencyController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController appointmentsController = TextEditingController();
  final TextEditingController urgentPolicyController = TextEditingController();

  // 🔥 NEW
  final TextEditingController maxRevisitController = TextEditingController();
  final TextEditingController revisitValidityController = TextEditingController();

  String? doctorKey;

  // 🔹 Prices
  final TextEditingController consultationPriceController = TextEditingController();
  final TextEditingController followUpPriceController = TextEditingController();
  final TextEditingController urgentConsultationPriceController = TextEditingController();

  // 🔹 Deposit
  final TextEditingController depositPercentController = TextEditingController();

  // 🔹 daily works
  final TextEditingController dailyWorksController = TextEditingController();

  bool is_update = false;
  int reserveWithDeposit = 0;

  ClinicModel? existingClinic;

  // ============================================================
  // 🔹 Populate
  // ============================================================
  void populateFields(ClinicModel clinic) {
    titleController.text = clinic.title ?? "";
    addressController.text = clinic.address ?? "";
    phone1Controller.text = clinic.phone1 ?? "";
    phone2Controller.text = clinic.phone2 ?? "";
    emergencyController.text = clinic.emergencyCall ?? "";
    locationController.text = clinic.location ?? "";
    whatsappController.text = clinic.whatsappNum ?? "";
    appointmentsController.text = clinic.appointments ?? "";
    urgentPolicyController.text = (clinic.urgentPolicy ?? 0).toString();

    consultationPriceController.text = clinic.consultationPrice ?? "";
    followUpPriceController.text = clinic.followUpPrice ?? "";
    urgentConsultationPriceController.text = clinic.urgentConsultationPrice ?? "";

    depositPercentController.text = clinic.minimumDepositPercent?.toString() ?? "";
    dailyWorksController.text = clinic.dailyWorks ?? "";

    // 🔥 NEW
    maxRevisitController.text = (clinic.maxRevisitCount ?? 0).toString();
    revisitValidityController.text = (clinic.revisitValidityDays ?? 0).toString();

    reserveWithDeposit = clinic.reserveWithDeposit ?? 0;
    is_update = true;
    update();
  }

  // ============================================================
  // 🔹 Save
  // ============================================================
  void saveClinic() {
    final clinic =
        existingClinic?.copyWith(
          title: titleController.text,
          address: addressController.text,
          phone1: phone1Controller.text,
          phone2: phone2Controller.text,
          emergencyCall: emergencyController.text,
          location: locationController.text,
          whatsappNum: whatsappController.text,
          urgentPolicy: int.tryParse(urgentPolicyController.text),
          appointments: appointmentsController.text,
          doctorKey: doctorKey ?? Get.find<UserSession>().user?.user.uid,

          consultationPrice: consultationPriceController.text,
          followUpPrice: followUpPriceController.text,
          urgentConsultationPrice: urgentConsultationPriceController.text,

          reserveWithDeposit: reserveWithDeposit,

          minimumDepositPercent:
          reserveWithDeposit == 1
              ? double.tryParse(depositPercentController.text) ?? 0
              : null,

          daillyWork: dailyWorksController.text,

          // 🔥 NEW
          maxRevisitCount: int.tryParse(maxRevisitController.text) ?? 0,
          revisitValidityDays: int.tryParse(revisitValidityController.text) ?? 0,
        ) ??
            ClinicModel(
              key: const Uuid().v4(),
              title: titleController.text,
              address: addressController.text,
              phone1: phone1Controller.text,
              phone2: phone2Controller.text,
              emergencyCall: emergencyController.text,
              location: locationController.text,
              whatsappNum: whatsappController.text,
              appointments: appointmentsController.text,
              urgentPolicy: int.tryParse(urgentPolicyController.text),
              doctorKey: doctorKey ?? Get.find<UserSession>().user?.user.uid,

              consultationPrice: consultationPriceController.text,
              followUpPrice: followUpPriceController.text,
              urgentConsultationPrice: urgentConsultationPriceController.text,

              reserveWithDeposit: reserveWithDeposit,

              minimumDepositPercent:
              reserveWithDeposit == 1
                  ? double.tryParse(depositPercentController.text) ?? 0
                  : null,

              dailyWorks: dailyWorksController.text,

              // 🔥 NEW
              maxRevisitCount: int.tryParse(maxRevisitController.text) ?? 0,
              revisitValidityDays: int.tryParse(revisitValidityController.text) ?? 0,
            );

    is_update ? updateClinic(clinic) : createClinic(clinic);
  }

  // ============================================================
  // 🔹 API
  // ============================================================
  void createClinic(ClinicModel clinic) {
    ClinicService().addClinicData(
      clinic: clinic,
      voidCallBack: (_) {
        refreshListView();
        Loader.showSuccess("تم إضافة العيادة بنجاح");
      },
    );
  }

  void updateClinic(ClinicModel clinic) {
    ClinicService().updateClinicData(
      clinic: clinic,
      voidCallBack: (_) {
        refreshListView();
        Loader.showSuccess("تم تحديث العيادة بنجاح");
      },
    );
  }

  void refreshListView() {
    final clinicVM = initController(() => ClinicViewModel());
    clinicVM.getData();
    clinicVM.update();
    Get.back();
  }

  // ============================================================
  // 🔹 Validation
  // ============================================================
  bool validateStep() {
    final requiredFilled =
        titleController.text.isNotEmpty &&
            urgentPolicyController.text.isNotEmpty &&
            phone1Controller.text.isNotEmpty &&
            addressController.text.isNotEmpty &&
            consultationPriceController.text.isNotEmpty &&
            followUpPriceController.text.isNotEmpty &&
            maxRevisitController.text.isNotEmpty &&
            revisitValidityController.text.isNotEmpty;

    final depositValid =
    reserveWithDeposit == 1
        ? depositPercentController.text.isNotEmpty
        : true;

    return requiredFilled && depositValid;
  }

  @override
  void dispose() {
    maxRevisitController.dispose();
    revisitValidityController.dispose();
    super.dispose();
  }
}