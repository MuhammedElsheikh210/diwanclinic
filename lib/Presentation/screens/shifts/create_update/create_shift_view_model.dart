import '../../../../../index/index_main.dart';

class CreateShiftViewModel extends GetxController {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  List<ClinicModel?>? listClinics;
  String? clinic_key;
  String? doctor_key;

  bool isUpdate = false;
  ShiftModel? existingShift;

  @override
  void onInit() {
    super.onInit();
    titleController.addListener(() => update());
    startTimeController.addListener(() => update());
    endTimeController.addListener(() => update());
  }

  void populateFields(ShiftModel shift) {
    titleController.text = shift.name ?? "";
    startTimeController.text = shift.startTime ?? "";
    endTimeController.text = shift.endTime ?? "";
    isUpdate = true;
    update();
  }

  void saveShift() {
    final shift =
        existingShift?.copyWith(
          name: titleController.text,
          startTime: startTimeController.text,
          endTime: endTimeController.text,
          clinicKey: clinic_key,
        ) ??
        ShiftModel(
          key: const Uuid().v4(),
          name: titleController.text,
          startTime: startTimeController.text,
          endTime: endTimeController.text,
          clinicKey: clinic_key,
          doctorKey:doctor_key ?? ""
        );

    isUpdate ? updateShift(shift) : createShift(shift);
  }



  void createShift(ShiftModel shift) {
    ShiftService().addShiftData(
      shift: shift,
      voidCallBack: (_) {
        refreshListView();
        Loader.showSuccess("تم إضافة الوردية بنجاح");
      },
    );
  }

  void updateShift(ShiftModel shift) {
    ShiftService().updateShiftData(
      shift: shift,
      voidCallBack: (_) {
        refreshListView();
        Loader.showSuccess("تم تحديث الوردية بنجاح");
      },
    );
  }

  void refreshListView() {
    final shiftVM = initController(() => ShiftViewModel());
    shiftVM.getData();
    shiftVM.update();
    Get.back();
  }

  bool validateStep() {
    return titleController.text.isNotEmpty &&
        startTimeController.text.isNotEmpty &&
        endTimeController.text.isNotEmpty;
  }

  @override
  void dispose() {
    titleController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }
}
