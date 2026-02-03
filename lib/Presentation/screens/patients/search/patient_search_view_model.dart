import '../../../../index/index_main.dart';

class PatientSearchViewModel extends GetxController {
  List<LocalUser?>? listPatients;
  late final TextEditingController textEditingController;

  @override
  void onInit() {
    super.onInit();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> getPatientsData({String? query}) async {
    if (query == null || query.isEmpty) {
      listPatients = null;
      update();
      return;
    }

    // ✅ Search only for patients (userType = "patient")
    //    and match client_name OR phone OR code
    const whereClause =
        '(userType = ? AND (client_name LIKE ? OR phone LIKE ? OR code LIKE ?))';
    final whereArgs = [
      'patient', // user type condition
      '%$query%',
      '%$query%',
      '%$query%',
    ];
    await AuthenticationService().getClientsLocalData(
      query: SQLiteQueryParams(where: whereClause, whereArgs: whereArgs),
      voidCallBack: (list) {
        listPatients = list;
        update();
      },
    );
  }
}
