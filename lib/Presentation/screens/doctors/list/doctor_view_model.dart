import '../../../../index/index_main.dart';

class DoctorViewModel extends GetxController {
  List<LocalUser?>? listDoctors;
  final String specializeKey;

  DoctorViewModel({required this.specializeKey});

  /// ✅ NEW Constructor for Medical Center
  DoctorViewModel.byCenter(String centerKey) : specializeKey = "" {
    getDoctorsByCenter(centerKey);
  }

  @override
  Future<void> onInit() async {
    if (specializeKey.isNotEmpty) {
      getData();
    }
    super.onInit();
  }

  void getData() {
    AuthenticationService().getClientsData(
      query: SQLiteQueryParams(
        where:
            "specialize_key = ? AND userType = ? AND remote_reservation_ability = ?",
        whereArgs: [specializeKey, "doctor", 1],
      ),
      voidCallBack: (data) {
        listDoctors = data;
        update();
      },
    );
  }

  /// ✅ NEW
  void getDoctorsByCenter(String centerKey) {
    print("centerKey is ${centerKey}");
    AuthenticationService().getClientsData(
      query: SQLiteQueryParams(
        where:
        "medicalCenterKey = ? AND userType = ? AND remote_reservation_ability = ?",
        whereArgs: [centerKey, "doctor", 1],
      ),
      voidCallBack: (data) {
        print("data in doctors is ${data.length}");
        listDoctors = data;
        update();
      },
    );
  }

  void deleteDoctor(LocalUser doctor) {
    AuthenticationService().deleteClientsData(
      uid: doctor.uid ?? "",
      voidCallBack: (_) {
        if (specializeKey.isNotEmpty) {
          getData();
        }
      },
    );
  }
}
