import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class OpenclosereservationViewModel extends GetxController {
  List<LegacyQueueModel?>? list;
  final LegacyQueueService service = LegacyQueueService();

  List<GenericListModel>? shiftDropdownItems;
  GenericListModel? selectedShift;

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
    getShiftList();
    getData();
  }

  // ============================================================
  // 🏥 SHIFT LIST
  // ============================================================
  Future<void> getShiftList() async {
    final clinicKey = LocalUser().getUserData().clinicKey;
    if (clinicKey == null) return;

    ShiftService().getShiftsData(
      data: FirebaseFilter(orderBy: "clinicKey", equalTo: clinicKey),
      doctorKey: LocalUser().getUserData().doctorKey ?? "",

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

        update();
      },
    );
  }

  // ============================================================
  // 📥 GET DATA (🏥 FILTER BY CLINIC ONLY)
  // ============================================================
  void getData() {
    final clinicKey = LocalUser().getUserData().clinicKey;
    if (clinicKey == null) return;

    service.getOpenCloseDaysByDateData(
      date: "", // مبقاش ليه استخدام
      firebaseFilter: FirebaseFilter(orderBy: "clinic_key", equalTo: clinicKey),
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
      date: "",
      key: model.key ?? "",
      voidCallBack: (status) {
        if (status == ResponseStatus.success) {
          getData();
        }
      },
    );
  }
}
