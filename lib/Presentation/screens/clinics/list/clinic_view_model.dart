import '../../../../../index/index_main.dart';

class ClinicViewModel extends GetxController {
  List<ClinicModel?>? listClinics;

  @override
  Future<void> onInit() async {
    getData();
    super.onInit();
  }

  void getData() {
    String uid = LocalUser().getUserData().uid ?? "";
    ClinicService().getClinicsData(
      data: {}, // optional filters
      filrebaseFilter: FirebaseFilter(),
      query: SQLiteQueryParams(),
      voidCallBack: (data) {
        Loader.dismiss();
        listClinics = data;
        update();
      },
    );
  }

  void deleteClinic(ClinicModel clinic) {
    ClinicService().deleteClinicData(
      clinicKey: clinic.key ?? "",
      voidCallBack: (_) {
        getData();
      },
    );
  }
}
