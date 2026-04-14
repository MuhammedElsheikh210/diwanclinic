import '../../../../../index/index_main.dart';

class PatientProfileHistoryViewModel extends GetxController {
  PatientModel? patientModel;
  List<FilesModel?>? list_files;

  @override
  Future<void> onInit() async {
    super.onInit();
  }

  void getData(ReservationModel model) {
    PatientService().getPatientsData(
      data: {}, // optional filters
      query: SQLiteQueryParams(
        is_filtered: true,
        where: "key = ? ",
        whereArgs: [model.patientUid ?? ""],
      ),
      isFiltered: true,
      voidCallBack: (data) {
        Loader.dismiss();
        if (data.isNotEmpty) {
          patientModel = data[0];
          getFilesForPatient(model.key ?? "");
        }

        update();
      },
    );
  }

  /// 🔹 Fetch all files linked to patient by reservation_key
  void getFilesForPatient(String reservation_key) {
    FilesService().getFilesData(
      data: {},
      query: SQLiteQueryParams(
        is_filtered: true,
        where: "reservation_key = ?",
        whereArgs: [reservation_key],
      ),
      isFiltered: true,
      voidCallBack: (data) {
        Loader.dismiss();
        list_files = data;
        update();
      },
    );
  }
}
