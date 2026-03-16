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

  String get formattedDate => DateFormat('dd-MM-yyyy').format(selectedDate);

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  /// 📅 Change Date
  void onDateChanged(DateTime date) {
    selectedDate = date;
    getData();
    update();
  }

  /// 📥 Get Data with Shift
  void getData() {
    service.getLegacyQueueByDateData(
      firebaseFilter: FirebaseFilter(
        orderBy: "clinic_key",
        equalTo: LocalUser().getUserData().clinicKey,
      ),
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
