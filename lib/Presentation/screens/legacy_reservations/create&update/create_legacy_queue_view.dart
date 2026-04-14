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

  /// 👨‍⚕️ Center Mode Support
  List<LocalUser?>? centerDoctors;
  LocalUser? selectedDoctor;
  bool isLoadingDoctors = false;

  bool get isCenterMode => false;

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

    if (isCenterMode) {
    } else {
      _loadShiftsForClinic();
    }
  }

  // ------------------------------------------------------------
  // 👨‍⚕️ LOAD DOCTORS
  // ------------------------------------------------------------

  // ------------------------------------------------------------
  // 🔹 LOAD SHIFTS
  // ------------------------------------------------------------
  Future<void> _loadShiftsForClinic() async {
    final currentUser = Get.find<UserSession>().user;

    if (currentUser == null || !currentUser.isAssistant) {
      debugPrint("❌ Current user is not assistant");
      return;
    }

    final assistant = currentUser.asAssistant;

    if (assistant == null) {
      debugPrint("❌ Failed to cast to AssistantUser");
      return;
    }

    // ✅ fallback (center mode)

    isLoadingShifts = true;
    update();

    try {
      await ShiftService().getShiftsData(
        data:
            isCenterMode
                ? FirebaseFilter()
                : FirebaseFilter(
                  orderBy: "clinicKey",
                  equalTo: assistant.clinicKey,
                ),

        doctorKey: assistant.doctorKey ?? "",

        query: isCenterMode ? SQLiteQueryParams() : SQLiteQueryParams(),

        voidCallBack: (data) {
          listShifts = data;

          shiftItems =
              (data ?? [])
                  .whereType<ShiftModel>()
                  .map(
                    (s) => GenericListModel(
                      key: s.key ?? "",
                      name: "${s.name ?? "فترة"} ",
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
      Loader.showError("فشل تحميل الفترات");
      isLoadingShifts = false;
      update();
    }
  } // ------------------------------------------------------------

  // 🔹 CHANGE DOCTOR
  // ------------------------------------------------------------
  Future<void> changeDoctor(LocalUser doctor) async {
    selectedDoctor = doctor;

    selectedShift = null;
    shiftItems = [];

    update();

    await _loadShiftsForClinic();
  }

  // ------------------------------------------------------------
  void selectShift(GenericListModel shift) {
    selectedShift = shift;
    update();
  }

  // ------------------------------------------------------------
  void setDate(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    selectedTimestamp = dateTime.millisecondsSinceEpoch;
    formattedDate = DateFormat("dd-MM-yyyy").format(dateTime);
    update();
  }

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
  // 💾 SAVE (🔥 UPDATED)
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

    final currentUser = Get.find<UserSession>().user;
    final clinicKey = currentUser?.asAssistant?.clinicKey;

    final doctorKey = selectedDoctor?.uid;

    final model = LegacyQueueModel(
      key: existing?.key ?? const Uuid().v4(),
      date: formattedDate,
      value: int.tryParse(valueController.text) ?? 0,
      clinic_key: clinicKey,
      shiftKey: selectedShift!.key,
      doctorKey: doctorKey,
    );

    Loader.show();

    if (isUpdate) {
      service.updateLegacyQueueData(
        model: model,
        doctorUid: isCenterMode ? doctorKey : null, // ✅ المهم
        voidCallBack: _handleResult,
      );
    } else {
      service.addLegacyQueueData(
        model: model,
        doctorUid: isCenterMode ? doctorKey : null, // ✅ المهم
        voidCallBack: _handleResult,
      );
    }
  }

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
