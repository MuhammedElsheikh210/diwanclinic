import '../../../../../index/index_main.dart';

class DoctorViewModel extends GetxController {
  List<LocalUser?>? listDoctors;
  final String specializeKey;

  DoctorViewModel({required this.specializeKey});

  @override
  Future<void> onInit() async {
    getData();
    super.onInit();
  }

  /// ✅ Fetch Doctors (filtered by specialization key)
  /// ✅ Fetch Doctors (filtered by specialization key)
  void getData() {
    AuthenticationService().getClientsData(
      query: SQLiteQueryParams(
        where:
            "specialize_key = ? AND userType = ? AND remote_reservation_ability = ?",
        whereArgs: [specializeKey, "doctor", 1],
      ),
      voidCallBack: (data) {
        Loader.dismiss();
        listDoctors = data;
        update();
      },
    );
  }

  /// ✅ Delete a Doctor
  void deleteDoctor(LocalUser doctor) {
    AuthenticationService().deleteClientsData(
      uid: doctor.uid ?? "",
      voidCallBack: (_) {
        getData();
      },
    );
  }
}
