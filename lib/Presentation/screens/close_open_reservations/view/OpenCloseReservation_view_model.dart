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

  String get formattedDate => DateFormat('dd / MM / yyyy').format(selectedDate);

  /// 🔒 هل اليوم الحالي مقفول؟
  bool get isSelectedDayClosed {
    if (list == null || list!.isEmpty) return false;
    return list!.first?.isClosed == true;
  }

  @override
  void onInit() {
    super.onInit();
    getData();
    getShiftList();
  }

  Future<void> getShiftList() async {
    final clinicKey = LocalUser().getUserData().clinicKey;
    if (clinicKey == null) return;

    ShiftService().getShiftsData(
      data: FirebaseFilter(orderBy: "clinicKey", equalTo: clinicKey),
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
            /// ✅ حالة شيفت واحد
            selectedShift = shiftDropdownItems!.first;
            _shiftInitialized = true;
            getData();
          } else {
            /// 🔥 أكتر من شيفت → افتح الديالوج
            showMandatoryShiftDialog();
          }
        } else {
          shiftDropdownItems = [];
        }

        update();
      },
    );
  }

  void showMandatoryShiftDialog() {
    if (shiftDropdownItems == null || shiftDropdownItems!.isEmpty) return;

    Get.dialog(
      ShiftSelectionDialog(
        shifts: shiftDropdownItems!,
        initialSelected: selectedShift,
        onSelect: (shift) {
          selectedShift = shift;
          _shiftInitialized = true;
          getData();
          update();
        },
      ),
      barrierDismissible: false,
    );
  }

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

  void onDateChanged(DateTime date) {
    selectedDate = date;
    getData();
    update();
  }

  void getData() {
    if (!_shiftInitialized || selectedShift == null) return;

    final formatted = DateFormat('dd-MM-yyyy').format(selectedDate);

    service.getOpenCloseDaysByDateData(
      date: formatted,
      shiftKey: selectedShift?.key ?? "", // 👈 مهم تضيفه في السيرفيس
      voidCallBack: (data) {
        list = data;
        update();
      },
    );
  }

  void deleteItem(LegacyQueueModel model) {
    service.deleteLegacyQueueData(
      date: model.date ?? "",
      key: model.key ?? "",
      voidCallBack: (status) {
        if (status == ResponseStatus.success) {
          getData();
        }
      },
    );
  }
}
