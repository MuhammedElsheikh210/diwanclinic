import '../../../../../index/index_main.dart';

class PharmacyViewModel extends GetxController {
  List<LocalUser?>? listPharmacies;

  @override
  Future<void> onInit() async {
    getData();
    super.onInit();
  }

  void getData() {
    AuthenticationService().getClientsData(
      query: SQLiteQueryParams(where: "userType = ?", whereArgs: ["pharmacy"]),
      voidCallBack: (data) {
        Loader.dismiss();
        listPharmacies = data;
        update();
      },
    );
  }

  void deletePharmacy(LocalUser? pharmacy) {
    AuthenticationService().deleteClientsData(
      uid: pharmacy?.uid ?? "",
      voidCallBack: (_) {
        getData();
      },
    );
  }
}
