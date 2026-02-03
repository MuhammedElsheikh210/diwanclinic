import '../../../../../index/index_main.dart';

class ShiftViewModel extends GetxController {
  List<ShiftModel?>? listShifts;
  String? clinic_key;

  @override
  Future<void> onInit() async {
    super.onInit();
  }

  void getData() {
    ShiftService().getShiftsData(
      data: FirebaseFilter(),
      query: SQLiteQueryParams(),
      voidCallBack: (data) {
        Loader.dismiss();
        listShifts = data;
        update();
      },
    );
  }

  void deleteShift(ShiftModel shift) {
    ShiftService().deleteShiftData(
      shiftKey: shift.key ?? "",
      voidCallBack: (_) => getData(),
    );
  }
}
