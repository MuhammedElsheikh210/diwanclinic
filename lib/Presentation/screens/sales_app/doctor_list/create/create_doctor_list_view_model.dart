import '../../../../../index/index_main.dart';

class CreateDoctorListViewModel extends GetxController {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController visitScheduleController = TextEditingController();

  bool isUpdate = false;
  DoctorListModel? existingDoctor;

  SpecializationModel? selectedSpecialization;
  final List<SpecializationModel> specializations = SpecializationMapper.all;

  String? selectedDoctorClass;
  final List<String> doctorClasses = const ["A", "B", "C"];

  @override
  void onInit() {
    super.onInit();

    /// 🔥 يخلي الزرار يتفعل فورًا
    nameController.addListener(update);
    visitScheduleController.addListener(update);
  }

  void populateFields(DoctorListModel doctor) {
    existingDoctor = doctor;

    nameController.text = doctor.name ?? "";
    visitScheduleController.text = doctor.visitSchedule ?? "";

    selectedSpecialization = SpecializationMapper.fromKey(
      doctor.specialization,
    );

    selectedDoctorClass = doctor.doctorClass;

    isUpdate = true;
    update();
  }

  void saveDoctor() {
    if (!validateStep()) return;

    final doctor = DoctorListModel(
      key: existingDoctor?.key ?? const Uuid().v4(),
      name: nameController.text.trim(),
      specialization: selectedSpecialization!.key,
      doctorClass: selectedDoctorClass!,
      visitSchedule: visitScheduleController.text.trim(),
    );

    isUpdate ? _updateDoctor(doctor) : _createDoctor(doctor);
  }

  void _createDoctor(DoctorListModel doctor) {
    DoctorListService().addDoctorData(
      doctor: doctor,
      voidCallBack: (_) {
        Loader.showSuccess("تم إضافة الدكتور");
        DoctorListViewModel doctorListViewModel = initController(
          () => DoctorListViewModel(),
        );
        doctorListViewModel.getData();
        doctorListViewModel.update();
        Get.back();
      },
    );
  }

  void _updateDoctor(DoctorListModel doctor) {
    DoctorListService().updateDoctorData(
      doctor: doctor,
      voidCallBack: (_) {
        Loader.showSuccess("تم تحديث الدكتور");
        DoctorListViewModel doctorListViewModel = initController(
          () => DoctorListViewModel(),
        );
        doctorListViewModel.getData();
        doctorListViewModel.update();
        Get.back();
      },
    );
  }

  bool validateStep() {
    return nameController.text.trim().isNotEmpty &&
        selectedSpecialization != null &&
        selectedDoctorClass != null &&
        visitScheduleController.text.trim().isNotEmpty;
  }

  @override
  void onClose() {
    nameController.dispose();
    visitScheduleController.dispose();
    super.onClose();
  }
}
