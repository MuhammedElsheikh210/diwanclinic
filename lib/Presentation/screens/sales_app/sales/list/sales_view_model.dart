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
      firebaseFilter: FirebaseFilter(orderBy: "userType", equalTo: "sales"),
      voidCallBack: (data) {
        Loader.dismiss();
        listSales = data as List<LocalUser?>?;
        update();
      },
    );
  }

  void deleteSales(LocalUser sales) {
    AuthenticationService().deleteClientsData(
      uid: sales.uid ?? "",
      voidCallBack: (_) {
        getData();
      },
    );
  }
}
