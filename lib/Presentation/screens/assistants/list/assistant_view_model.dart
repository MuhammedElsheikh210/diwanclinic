import '../../../../../index/index_main.dart';

class AssistantViewModel extends GetxController {
  List<LocalUser?>? listAssistants;

  /// 🧠 OLD MODE (Doctor Assistants)
  AssistantViewModel() {
    getData();
  }

  /// 🏥 NEW MODE (Center Assistants)
  AssistantViewModel.byCenter(String centerKey) {
    getAssistantsByCenter(centerKey);
  }

  // =========================================================
  // 👨‍⚕️ Doctor Assistants
  // =========================================================

  void getData() {
    final doctorUid = LocalUser().getUserData().uid ?? "";

    AuthenticationService().getClientsData(
      query: SQLiteQueryParams(
        where: "doctor_key = ? AND userType = ?",
        whereArgs: [doctorUid, "assistant"],
      ),
      voidCallBack: (data) {
        listAssistants = data;
        update();
      },
    );
  }

  // =========================================================
  // 🏥 Center Assistants
  // =========================================================

  void getAssistantsByCenter(String centerKey) {
    AuthenticationService().getClientsData(
      query: SQLiteQueryParams(
        where: "medicalCenterKey = ? AND userType = ?",
        whereArgs: [centerKey, "assistant"],
      ),
      voidCallBack: (data) {
        listAssistants = data;
        update();
      },
    );
  }

  // =========================================================

  void deleteAssistant(LocalUser assistant) {
    AuthenticationService().deleteClientsData(
      uid: assistant.uid ?? "",
      voidCallBack: (_) {
        getData();
      },
    );
  }
}
