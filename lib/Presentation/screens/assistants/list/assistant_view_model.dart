import '../../../../../index/index_main.dart';

class AssistantViewModel extends GetxController {
  List<LocalUser?>? listAssistants;

  @override
  Future<void> onInit() async {
    getData();
    super.onInit();
  }

  void getData() {
    final doctorUid = LocalUser().getUserData().uid ?? "";

    AuthenticationService().getClientsData(
      query: SQLiteQueryParams(
        where: "doctor_key = ? AND userType = ?",
        whereArgs: [doctorUid, "assistant"],
      ),
      voidCallBack: (data) {
        Loader.dismiss();
        listAssistants = data;
        update();
      },
    );
  }

  void deleteAssistant(LocalUser assistant) {
    AuthenticationService().deleteClientsData(
      uid: assistant.uid ?? "",
      voidCallBack: (_) {
        getData();
      },
    );
  }
}
