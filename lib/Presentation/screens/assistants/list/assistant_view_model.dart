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
      firebaseFilter: FirebaseFilter(orderBy: "doctor_key", equalTo: doctorUid),
      query: SQLiteQueryParams(where: "doctor_key", whereArgs: [doctorUid]),
      voidCallBack: (data) {
        Loader.dismiss();

        // filter assistants only
        listAssistants = (data as List<LocalUser?>?)
            ?.where((u) => u?.userType?.name == Strings.assistant)
            .toList();

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
