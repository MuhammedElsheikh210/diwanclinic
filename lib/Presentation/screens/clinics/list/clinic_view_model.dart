import '../../../../../index/index_main.dart';

class ClinicViewModel extends GetxController {
  final String? doctorKey;

  ClinicViewModel({this.doctorKey});

  List<ClinicModel?>? listClinics;

  @override
  Future<void> onInit() async {
    super.onInit();

    getData();
  }

  void getData() {
    final user = Get.find<UserSession>().user?.user;
    final String uid =
        doctorKey ??
        (user is AssistantUser ? user.doctorKey : user?.uid) ??
        (throw Exception("❌ UID missing"));

    ClinicService().getClinicsData(
      data: {},
      fromOnline: true,
      doctorKey: doctorKey ?? "",

      /// 🔹 Firebase filter
      filrebaseFilter: FirebaseFilter(),

      /// 🔹 SQLite filter
      query: SQLiteQueryParams(where: "doctor_key = ?", whereArgs: [uid]),

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
      doctorKey: clinic.doctorKey ?? "",
      voidCallBack: (_) {
        getData();
      },
    );
  }
}
