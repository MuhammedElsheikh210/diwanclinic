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

  final LegacyQueueService service = LegacyQueueService();

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
  }

  /// 📅 Date Picker handler
  void setDate(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    selectedTimestamp = dateTime.millisecondsSinceEpoch;
    formattedDate = DateFormat("dd-MM-yyyy").format(dateTime);
    update();
  }

  /// 🔎 Validation
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

  void save() {
    if (!formKey.currentState!.validate()) return;

    if (formattedDate == null) {
      Loader.showError("يرجى اختيار التاريخ");
      return;
    }

    final model = LegacyQueueModel(
      key: existing?.key ?? const Uuid().v4(),
      date: formattedDate,
      value: int.tryParse(valueController.text) ?? 0,
      clinic_key: LocalUser().getUserData().clinicKey,
    );

    Loader.show();

    if (isUpdate) {
      service.updateLegacyQueueData(model: model, voidCallBack: _handleResult);
    } else {
      service.addLegacyQueueData(model: model, voidCallBack: _handleResult);
    }
  }

  /// 🔄 Handle success / error
  void _handleResult(ResponseStatus status) {
    Loader.dismiss();

    if (status == ResponseStatus.success) {
      _refreshList();
      Get.back();
    } else {
      Loader.showError("حدث خطأ، حاول مرة أخرى");
    }
  }

  /// 🔄 Reload Legacy Queue list safely
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
