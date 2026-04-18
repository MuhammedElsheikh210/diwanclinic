import '../../../../index/index_main.dart';

class DoctorViewModel extends GetxController {
  List<LocalUser?>? listDoctors;
  final String specializeKey;

  DoctorViewModel({required this.specializeKey});

  @override
  Future<void> onInit() async {
    if (specializeKey.isNotEmpty) {
      getData();
    }
    super.onInit();
  }

  void getData() {
    AuthenticationService().getClientsOnlineData(
      firebaseFilter: FirebaseFilter(orderBy: "userType", equalTo: "doctor"),
      voidCallBack: (users) {
        listDoctors = users;
        update();
      },
    );
  }

  /// ✅ NEW

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
