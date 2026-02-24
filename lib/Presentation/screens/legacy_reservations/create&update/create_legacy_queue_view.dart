import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class CreateLegacyQueueViewModel extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController valueController = TextEditingController();
  final FocusNode valueFocusNode = FocusNode();

  bool isUpdate = false;
  LegacyQueueModel? existing;

  int? selectedTimestamp;
  String? formattedDate;

  // 🔹 Shift Data
  List<ShiftModel?>? listShifts;
  List<GenericListModel> shiftItems = [];
  GenericListModel? selectedShift;
  bool isLoadingShifts = false;

  final LegacyQueueService service = LegacyQueueService();

  // ------------------------------------------------------------
  // 🔹 INIT
  // ------------------------------------------------------------
  void init(LegacyQueueModel? model) {
    if (model != null) {
      existing = model;
      isUpdate = true;

      valueController.text = model.value?.toString() ?? "";

      try {
        final parsed = DateFormat("dd-MM-yyyy").parse(model.date ?? "");
        selectedTimestamp = parsed.millisecondsSinceEpoch;
        formattedDate = model.date;
      } catch (_) {}
    }

    _loadShiftsForClinic(); // 🔥 load shifts on init
  }

  // ------------------------------------------------------------
  // 🔹 Load Shifts According to Clinic
  // ------------------------------------------------------------
  Future<void> _loadShiftsForClinic() async {
    final clinicKey = LocalUser().getUserData().clinicKey;

    if (clinicKey == null || clinicKey.isEmpty) return;

    isLoadingShifts = true;
    update();

    try {
      await ShiftService().getShiftsData(
        data: FirebaseFilter(orderBy: "clinicKey", equalTo: clinicKey),
        query: SQLiteQueryParams(
          is_filtered: true,
          where: "clinicKey = ?",
          whereArgs: [clinicKey],
        ),
        voidCallBack: (data) {
          Loader.dismiss();

          listShifts = data;

          shiftItems = (data ?? [])
              .whereType<ShiftModel>()
              .map(
                (s) => GenericListModel(
                  key: s.key ?? "",
                  name: "${s.name ?? "فترة"} (${s.dayOfWeek ?? ""})",
                ),
              )
              .toList();

          if (shiftItems.isNotEmpty) {
            selectedShift = shiftItems.first;
          }

          isLoadingShifts = false;
          update();
        },
      );
    } catch (e) {
      Loader.dismiss();
      Loader.showError("فشل تحميل الفترات");
      isLoadingShifts = false;
      update();
    }
  }

  // ------------------------------------------------------------
  // 🔹 Select Shift
  // ------------------------------------------------------------
  void selectShift(GenericListModel shift) {
    selectedShift = shift;
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
  // 🔎 Validation
  // ------------------------------------------------------------
  String? validateValue(String? val) {
    if (val == null || val.isEmpty) {
      return "العدد مطلوب";
    }

    final parsed = int.tryParse(val);
    if (parsed == null || parsed <= 0) {
      return "ادخل رقم صحيح أكبر من صفر";
    }

    return null;
  }

  // ------------------------------------------------------------
  // 💾 SAVE
  // ------------------------------------------------------------
  void save() {
    if (!formKey.currentState!.validate()) return;

    if (formattedDate == null) {
      Loader.showError("يرجى اختيار التاريخ");
      return;
    }

    if (selectedShift == null) {
      Loader.showError("يرجى اختيار الفترة");
      return;
    }

    final clinicKey = LocalUser().getUserData().clinicKey ?? "";
    final shiftKey = selectedShift!.key ?? "";

    final model = LegacyQueueModel(
      key: existing?.key ?? const Uuid().v4(),
      date: formattedDate,
      value: int.tryParse(valueController.text) ?? 0,
      clinic_key: clinicKey,
      shiftKey: shiftKey,
      // ❌ لا تحتاج تمرر clinicShiftKey لو الموديل بيولده تلقائي
    );

    Loader.show();

    if (isUpdate) {
      service.updateLegacyQueueData(model: model, voidCallBack: _handleResult);
    } else {
      service.addLegacyQueueData(model: model, voidCallBack: _handleResult);
    }
  }

  // ------------------------------------------------------------
  // 🔄 Handle Result
  // ------------------------------------------------------------
  void _handleResult(ResponseStatus status) {
    Loader.dismiss();

    if (status == ResponseStatus.success) {
      _refreshList();
      Get.back();
    } else {
      Loader.showError("حدث خطأ، حاول مرة أخرى");
    }
  }

  void _refreshList() {
    if (Get.isRegistered<LegacyQueueViewModel>()) {
      final legacyVM = Get.find<LegacyQueueViewModel>();
      legacyVM.getData();
    }
  }

  @override
  void dispose() {
    valueController.dispose();
    valueFocusNode.dispose();
    super.dispose();
  }
}
