import '../../../../../index/index_main.dart';

class PatientViewModel extends GetxController {
  List<PatientModel?>? listPatients;

  @override
  Future<void> onInit() async {
    getData();
    super.onInit();
  }

  void getData() {
    PatientService().getPatientsData(
      data: {}, // optional filters
      query: SQLiteQueryParams(is_filtered: false),
      isFiltered: false,
      voidCallBack: (data) {
        Loader.dismiss();
        listPatients = data;
        update();
      },
    );
  }

  void deletePatient(PatientModel patient) {
    PatientService().deletePatientData(
      patientKey: patient.key ?? "",
      voidCallBack: (_) {
        getData();
      },
    );
  }
}
