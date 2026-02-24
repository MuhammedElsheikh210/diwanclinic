import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class LegacyQueueViewModel extends GetxController {
  final LegacyQueueService service = LegacyQueueService();

  List<LegacyQueueModel?>? list;

  /// 🕒 Shift
  List<GenericListModel>? shiftDropdownItems;
  GenericListModel? selectedShift;
  bool _shiftInitialized = false;

  /// 📅 Date
  DateTime selectedDate = DateTime.now();

  String get formattedDate => DateFormat('dd / MM / yyyy').format(selectedDate);

  @override
  void onInit() {
    super.onInit();
    getShiftList();
  }

  /// 🕒 Get Shifts
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
      voidCallBack: (data) {
        if (data != null && data.isNotEmpty) {
          shiftDropdownItems = ShiftModelAdapterUtil.convertShiftListToGeneric(
            data,
          );

          if (shiftDropdownItems!.length == 1) {
            selectedShift = shiftDropdownItems!.first;
            _shiftInitialized = true;
            getData();
          } else {
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

  /// 📅 Change Date
  void onDateChanged(DateTime date) {
    selectedDate = date;
    getData();
    update();
  }

  /// 📥 Get Data with Shift
  void getData() {
    if (!_shiftInitialized || selectedShift == null) return;

    final formatted = DateFormat('dd-MM-yyyy').format(selectedDate);

    service.getLegacyQueueByDateData(
      date: formatted,
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
