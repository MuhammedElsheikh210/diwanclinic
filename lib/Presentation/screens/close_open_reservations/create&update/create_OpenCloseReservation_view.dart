import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class CreateOpenclosereservationViewModel extends GetxController {
  final TextEditingController valueController = TextEditingController();

  bool isUpdate = false;
  LegacyQueueModel? existing;

  int? selectedTimestamp;
  String? formattedDate;

  /// 👨‍⚕️ Doctors (Center Mode)
  List<LocalUser?>? centerDoctors;
  LocalUser? selectedDoctor;
  bool isLoadingDoctors = false;

  bool get isCenterMode => LocalUser().getUserData().medicalCenterKey != null;

  /// 🔒 اليوم مقفول؟
  bool isClosed = false;

  /// ⏰ Shift
  List<GenericListModel>? shiftDropdownItems;
  GenericListModel? selectedShift;
  String? shiftKey;

  final LegacyQueueService service = LegacyQueueService();

  // ------------------------------------------------------------
  // 🔹 INIT
  // ------------------------------------------------------------
  void init(LegacyQueueModel? model, {String? incomingShiftKey}) {
    shiftKey = incomingShiftKey;

    if (model != null) {
      existing = model;
      isUpdate = true;

      valueController.text = model.value?.toString() ?? "0";
      isClosed = model.isClosed ?? false;

      try {
        final parsed = DateFormat("dd-MM-yyyy").parse(model.date ?? "");
        selectedTimestamp = parsed.millisecondsSinceEpoch;
        formattedDate = model.date;
      } catch (_) {}
    }

    if (isCenterMode) {
      loadDoctorsOfCenter();
    } else {
      loadShiftList();
    }
  }

  // ------------------------------------------------------------
  // 👨‍⚕️ LOAD DOCTORS
  // ------------------------------------------------------------
  Future<void> loadDoctorsOfCenter() async {
    final centerKey = LocalUser().getUserData().medicalCenterKey;
    if (centerKey == null) return;

    isLoadingDoctors = true;
    update();

    AuthenticationService().getClientsData(
      query: SQLiteQueryParams(
        where: "medicalCenterKey = ? AND userType = ?",
        whereArgs: [centerKey, "doctor"],
      ),
      voidCallBack: (data) async {
        centerDoctors = data;

        if (data.isNotEmpty) {
          selectedDoctor = data.first;

          await loadShiftList();
        }

        isLoadingDoctors = false;
        update();
      },
    );
  }

  // ------------------------------------------------------------
  // 🔹 LOAD SHIFTS (FIXED)
  // ------------------------------------------------------------
  Future<void> loadShiftList() async {
    final clinicKey =
        isCenterMode
            ? selectedDoctor?.clinicKey ?? ""
            : LocalUser().getUserData().clinicKey ?? "";

    final doctorKey =
        isCenterMode
            ? selectedDoctor?.uid ?? ""
            : LocalUser().getUserData().doctorKey ?? "";

    print("clinick key is ${clinicKey}");

    ShiftService().getShiftsData(
      data:
          isCenterMode
              ? FirebaseFilter()
              : FirebaseFilter(orderBy: "clinicKey", equalTo: clinicKey),
      doctorKey: doctorKey,
      query:
          isCenterMode
              ? SQLiteQueryParams()
              : SQLiteQueryParams(
                is_filtered: true,
                where: "clinicKey = ?",
                whereArgs: [clinicKey],
              ),
      voidCallBack: (data) {
        if (data != null && data.isNotEmpty) {
          shiftDropdownItems = ShiftModelAdapterUtil.convertShiftListToGeneric(
            data,
          );

          /// ✅ لو واحد بس
          if (shiftDropdownItems!.length == 1) {
            selectedShift = shiftDropdownItems!.first;
            shiftKey = selectedShift!.key;
          } else {
            /// ✅ restore لو جاي من edit
            if (shiftKey != null) {
              try {
                selectedShift = shiftDropdownItems!.firstWhere(
                  (e) => e.key == shiftKey,
                );
              } catch (_) {
                selectedShift = null;
              }
            }
          }
        } else {
          shiftDropdownItems = [];
          selectedShift = null;
        }

        update();
      },
    );
  }

  // ------------------------------------------------------------
  // 🔹 CHANGE DOCTOR (FIXED)
  // ------------------------------------------------------------
  Future<void> changeDoctor(LocalUser doctor) async {
    selectedDoctor = doctor;

    /// reset
    selectedShift = null;
    shiftKey = null;
    shiftDropdownItems = [];

    update();

    await loadShiftList();
  }

  // ------------------------------------------------------------
  void selectShift(GenericListModel shift) {
    selectedShift = shift;
    shiftKey = shift.key;
    update();
  }

  // ------------------------------------------------------------
  void setDate(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    selectedTimestamp = dateTime.millisecondsSinceEpoch;
    formattedDate = DateFormat("dd-MM-yyyy").format(dateTime);
    update();
  }

  void toggleClosed(bool value) {
    isClosed = value;
    update();
  }

  // ------------------------------------------------------------
  void save() {
    if (formattedDate == null) {
      Loader.showError("يرجى اختيار التاريخ");
      return;
    }

    if (shiftKey == null || shiftKey!.isEmpty) {
      Loader.showError("يرجى اختيار الفترة");
      return;
    }

    final model = LegacyQueueModel(
      key: existing?.key ?? const Uuid().v4(),
      date: formattedDate,
      shiftName: selectedShift?.name,
      value: int.tryParse(valueController.text) ?? 0,
      clinic_key:
          isCenterMode
              ? selectedDoctor?.clinicKey
              : LocalUser().getUserData().clinicKey,
      isClosed: isClosed,
      shiftKey: shiftKey,
      doctorKey:
          isCenterMode
              ? selectedDoctor?.uid
              : LocalUser().getUserData().doctorKey,
    );

    Loader.show();

    if (isUpdate) {
      service.updateOpenCloseDayData(
        model: model,
        voidCallBack: _handleResult,
        doctorUid: isCenterMode ? model.doctorKey : null,
      );
    } else {
      service.addOpenCloseDayData(
        model: model,
        voidCallBack: _handleResult,
        doctorUid: isCenterMode ? model.doctorKey : null,
      );
    }
  }

  void _handleResult(ResponseStatus status) {
    Loader.dismiss();

    if (status == ResponseStatus.success) {
      final vm = Get.find<OpenclosereservationViewModel>();
      vm.getData();
      vm.update();
      Get.back();
    } else {
      Loader.showError("حدث خطأ، حاول مرة أخرى");
    }
  }

  @override
  void dispose() {
    valueController.dispose();
    super.dispose();
  }
}
