import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class OpenclosereservationViewModel extends GetxController {
  List<LegacyQueueModel?>? list;
  final LegacyQueueService service = LegacyQueueService();

  List<GenericListModel>? shiftDropdownItems;
  GenericListModel? selectedShift;

  List<LocalUser?>? centerDoctors;
  LocalUser? selectedDoctor;
  bool isLoadingDoctors = false;

  bool get isCenterMode => LocalUser().getUserData().medicalCenterKey != null;

  bool _shiftInitialized = false;

  /// 📅 selected date (default = today)
  DateTime selectedDate = DateTime.now();

  String get formattedDate => DateFormat('dd-MM-yyyy').format(selectedDate);

  /// 🔒 هل اليوم الحالي مقفول؟
  bool get isSelectedDayClosed {
    if (list == null || list!.isEmpty) return false;
    return list!.first?.isClosed == true;
  }

  @override
  void onInit() {
    super.onInit();
    if (isCenterMode) {
      loadDoctorsOfCenter();
    } else {
      //getShiftList();
      getData();
    }
  }

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

          // await getShiftList(clinic_key: selectedDoctor?.clinicKey); // 👈 مهم
          getData(); // 👈 reload
        }

        isLoadingDoctors = false;
        update();
      },
    );
  }

  // ============================================================
  // 🏥 SHIFT LIST
  // ============================================================
  Future<void> getShiftList({String? clinic_key}) async {
    final clinicKey = clinic_key ?? LocalUser().getUserData().clinicKey;
    if (clinicKey == null) return;

    ShiftService().getShiftsData(
      data: FirebaseFilter(orderBy: "clinicKey", equalTo: clinicKey),
      doctorKey:
          isCenterMode
              ? selectedDoctor?.uid ?? ""
              : LocalUser().getUserData().doctorKey ?? "",
      query: SQLiteQueryParams(
        is_filtered: true,
        where: "clinicKey = ?",
        whereArgs: [clinicKey],
      ),
      voidCallBack: (data) async {
        if (data != null && data.isNotEmpty) {
          shiftDropdownItems = ShiftModelAdapterUtil.convertShiftListToGeneric(
            data,
          );

          if (shiftDropdownItems!.length == 1) {
            selectedShift = shiftDropdownItems!.first;
            _shiftInitialized = true;
          }
        } else {
          shiftDropdownItems = [];
        }
        print("selectedShift is ${selectedShift?.toJson()}");
        update();
      },
    );
  }

  // ============================================================
  // 📥 GET DATA (🏥 FILTER BY CLINIC ONLY)
  // ============================================================
  void getData() {
    service.getOpenCloseDaysByDateData(
      date: "", // مبقاش ليه استخدام
      firebaseFilter:
          isCenterMode
              ? FirebaseFilter()
              : FirebaseFilter(
                orderBy: "clinic_key",
                equalTo: LocalUser().getUserData().clinicKey,
              ),
      doctorUid: selectedDoctor?.uid,

      voidCallBack: (data) {
        list = data;
        update();
      },
    );
  }

  // ============================================================
  // 🔄 CHANGE DATE (للاستخدام المستقبلي)
  // ============================================================
  void onDateChanged(DateTime date) {
    selectedDate = date;
    update();
  }

  // ============================================================
  // 🔒 TOGGLE DAY STATUS
  // ============================================================
  void toggleDayStatus(LegacyQueueModel model, {required bool isClosed}) {
    final updated = model.copyWith(isClosed: isClosed);

    service.updateLegacyQueueData(
      model: updated,
      doctorUid: selectedDoctor?.uid,

      voidCallBack: (status) {
        if (status == ResponseStatus.success) {
          Loader.dismiss();
          getData();
        }
      },
    );
  }

  // ============================================================
  // 🗑 DELETE
  // ============================================================
  void deleteItem(LegacyQueueModel model) {
    service.deleteLegacyQueueData(
      doctorUid: isCenterMode ? selectedDoctor?.uid : null,
      // ✅ مهم
      date: "",
      key: model.key ?? "",
      isOpenClosed: true,
      voidCallBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          getData();
        }
      },
    );
  }
}
