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
    /// doctorKey لو جاي من الادمن
    /// غير كده نستخدم المستخدم الحالي
    final String uid = doctorKey ?? LocalUser().getUserData().uid ?? "";

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
