import '../../../../../index/index_main.dart';

class CreatePatientViewModel extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  bool is_update = false;
  PatientModel? existingPatient;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(() => update());
    phoneController.addListener(() => update());
  }

  void populateFields(PatientModel patient) {
    nameController.text = patient.name ?? "";
    phoneController.text = patient.phone ?? "";
    addressController.text = patient.address ?? "";
    birthdayController.text = patient.birthday ?? "";
    is_update = true;
    update();
  }

  void savePatient() {
    final patient = existingPatient?.copyWith(
      name: nameController.text,
      phone: phoneController.text,
      address: addressController.text,
      birthday: birthdayController.text,
    ) ??
        PatientModel(
          key: const Uuid().v4(),
          name: nameController.text,
          phone: phoneController.text,
          address: addressController.text,
          birthday: birthdayController.text,
        );

    is_update ? updatePatient(patient) : createPatient(patient);
  }

  void createPatient(PatientModel patient) {
    PatientService().addPatientData(
      patient: patient,
      voidCallBack: (_) {
        refreshListView();
        Loader.showSuccess("تم إضافة المريض بنجاح");
      },
    );
  }

  void updatePatient(PatientModel patient) {
    PatientService().updatePatientData(
      patient: patient,
      voidCallBack: (_) {
        refreshListView();
        Loader.showSuccess("تم تحديث المريض بنجاح");
      },
    );
  }

  void refreshListView() {
    final patientVM = initController(() => PatientViewModel());
    patientVM.getData();
    patientVM.update();
    Get.back();
  }

  bool validateStep() {
    return nameController.text.isNotEmpty && phoneController.text.isNotEmpty;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    birthdayController.dispose();
    super.dispose();
  }
}
