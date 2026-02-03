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
      firebaseFilter: FirebaseFilter(
        orderBy: "specialize_key",
        equalTo: specializeKey,
      ),
      query: SQLiteQueryParams(is_filtered: false),
      isFiltered: false,
      voidCallBack: (data) {
        Loader.dismiss();

        // ✅ Filter ONLY doctors who allow remote reservations
        listDoctors = (data as List<LocalUser?>?)
            ?.where(
              (user) =>
                  user?.userType == UserType.doctor &&
                  (user?.remote_reservation_ability ?? 0) == 1,
            )
            .toList();

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
