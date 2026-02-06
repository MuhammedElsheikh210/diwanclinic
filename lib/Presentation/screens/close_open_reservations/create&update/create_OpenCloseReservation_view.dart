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

  final LegacyQueueService service = LegacyQueueService();

  void init(LegacyQueueModel? model) {
    if (model != null) {
      existing = model;
      isUpdate = true;

      valueController.text = model.value?.toString() ?? "0";
      isClosed = model.isClosed ?? false; // 👈 الجديد

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

  /// 🔁 Toggle close / open day
  void toggleClosed(bool value) {
    isClosed = value;
    update();
  }

  void save() {
    if (formattedDate == null) {
      Loader.showError("يرجى اختيار التاريخ");
      return;
    }

    final model = LegacyQueueModel(
      key: existing?.key ?? const Uuid().v4(),
      date: formattedDate,
      value: int.tryParse(valueController.text) ?? 0,
      clinic_key: LocalUser().getUserData().clinicKey,
      isClosed: isClosed, // 👈 المهم
    );

    Loader.show();

    if (isUpdate) {
      service.updateLegacyQueueData(
        model: model,
        voidCallBack: (status) {
          _handleResult(status);
        },
      );
    } else {
      service.addLegacyQueueData(
        model: model,
        voidCallBack: (status) {
          _handleResult(status);
        },
      );
    }
  }

  /// 🔄 Handle success / error
  void _handleResult(ResponseStatus status) {
    Loader.dismiss();

    if (status == ResponseStatus.success) {
      _refreshList();
      Get.back(); // close bottom sheet
    } else {
      Loader.showError("حدث خطأ، حاول مرة أخرى");
    }
  }

  /// 🔄 Reload Legacy Queue list
  void _refreshList() {
    final legacyVM = initController(() => LegacyQueueViewModel());
    legacyVM.getData();
    legacyVM.update();
  }

  @override
  void dispose() {
    valueController.dispose();
    super.dispose();
  }
}
