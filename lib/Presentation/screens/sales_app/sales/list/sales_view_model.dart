import '../../../../../index/index_main.dart';

class SalesViewModel extends GetxController {
  List<LocalUser?>? listSales;

  @override
  Future<void> onInit() async {
    getData();
    super.onInit();
  }

  void getData() {
    AuthenticationService().getClientsData(
      query: SQLiteQueryParams(where: "userType = ?", whereArgs: ["sales"]),
      voidCallBack: (data) {
        Loader.dismiss();
        listSales = data;
        update();
      },
    );
  }

  void deleteSales(LocalUser? sales) {
    AuthenticationService().deleteClientsData(
      uid: sales?.uid ?? "",
      voidCallBack: (_) {
        getData();
      },
    );
  }
}
