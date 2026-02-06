import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class OpenclosereservationViewModel extends GetxController {
  List<LegacyQueueModel?>? list;
  final LegacyQueueService service = LegacyQueueService();

  /// 📅 selected date (default = today)
  DateTime selectedDate = DateTime.now();

  String get formattedDate =>
      DateFormat('dd / MM / yyyy').format(selectedDate);

  /// 🔒 هل اليوم الحالي مقفول؟
  bool get isSelectedDayClosed {
    if (list == null || list!.isEmpty) return false;
    return list!.first?.isClosed == true;
  }

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  void toggleDayStatus(
      LegacyQueueModel model, {
        required bool isClosed,
      }) {
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
    final formatted = DateFormat('dd-MM-yyyy').format(selectedDate);

    service.getOpenCloseDaysByDateData(
      date: formatted, // 👈 نجيب يوم واحد
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
