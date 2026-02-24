import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class CreateOpenclosereservationViewModel extends GetxController {
  final TextEditingController valueController = TextEditingController();

  bool isUpdate = false;
  LegacyQueueModel? existing;

  int? selectedTimestamp;
  String? formattedDate;

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
  void init(
      LegacyQueueModel? model, {
        String? incomingShiftKey,
      }) {
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

    loadShiftList();
  }

  // ------------------------------------------------------------
  // 🔹 LOAD SHIFTS
  // ------------------------------------------------------------
  Future<void> loadShiftList() async {
    final clinicKey = LocalUser().getUserData().clinicKey ?? "";

    ShiftService().getShiftsData(
      data: FirebaseFilter(orderBy: "clinicKey", equalTo: clinicKey),
      query: SQLiteQueryParams(
        is_filtered: true,
        where: "clinicKey = ?",
        whereArgs: [clinicKey],
      ),
      voidCallBack: (data) {
        if (data != null && data.isNotEmpty) {
          shiftDropdownItems =
              ShiftModelAdapterUtil.convertShiftListToGeneric(data);

          if (shiftDropdownItems!.length == 1) {
            selectedShift = shiftDropdownItems!.first;
            shiftKey = selectedShift!.key;
          } else {
            if (shiftKey != null) {
              try {
                selectedShift = shiftDropdownItems!
                    .firstWhere((e) => e.key == shiftKey);
              } catch (_) {
                selectedShift = null;
              }
            }
          }
        }

        update();
      },
    );
  }

  // ------------------------------------------------------------
  // 🔹 Select Shift manually
  // ------------------------------------------------------------
  void selectShift(GenericListModel shift) {
    selectedShift = shift;
    shiftKey = shift.key;
    update();
  }

  // ------------------------------------------------------------
  // 📅 Date Picker
  // ------------------------------------------------------------
  void setDate(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    selectedTimestamp = dateTime.millisecondsSinceEpoch;
    formattedDate = DateFormat("dd-MM-yyyy").format(dateTime);
    update();
  }

  // ------------------------------------------------------------
  // 🔁 Toggle close / open
  // ------------------------------------------------------------
  void toggleClosed(bool value) {
    isClosed = value;
    update();
  }

  // ------------------------------------------------------------
  // 💾 SAVE
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
      value: int.tryParse(valueController.text) ?? 0,
      clinic_key: LocalUser().getUserData().clinicKey,
      isClosed: isClosed,
      shiftKey: shiftKey,
    );

    Loader.show();

    if (isUpdate) {
      service.updateOpenCloseDayData(
        model: model,
        voidCallBack: _handleResult,
      );
    } else {
      service.addOpenCloseDayData(
        model: model,
        voidCallBack: _handleResult,
      );
    }
  }

  // ------------------------------------------------------------
  // 🔄 Result Handler
  // ------------------------------------------------------------
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