
import '../../../../../index/index_main.dart';

class MedicalCenterViewModel extends GetxController {
  List<MedicalCenterModel?>? centers;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  /// 🏥 Fetch All Medical Centers
  void getData() {
    MedicalCenterService().getAllMedicalCentersData(
      voidCallBack: (data) {
        centers = data;
        update();
      },
    );
  }

  /// 🔄 Refresh
  Future<void> refreshData() async {
    getData();
  }

  /// 🗑 Delete Center
  void deleteCenter(String key) {
    MedicalCenterService().deleteMedicalCenterData(
      key: key,
      voidCallBack: (_) {
        getData();
      },
    );
  }
}