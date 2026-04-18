import '../../../../../index/index_main.dart';

class AssistantViewModel extends GetxController {
  List<LocalUser?>? listAssistants;
  String? doctorUid; // ✅ خزّناه هنا

  /// 🏥 NEW MODE (Center Assistants)
  AssistantViewModel.byCenter(String centerKey) {
    getAssistantsByCenter(centerKey);
  }

  // =========================================================
  // 👨‍⚕️ Doctor Assistants
  // =========================================================

  void getData({String? doctor_uid}) {
    
    
    AuthenticationService().getClientsData(
      query: SQLiteQueryParams(
        where: "doctor_key = ? AND userType = ?",
        whereArgs: [doctor_uid ?? doctorUid, "assistant"],
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

  void deleteAssistant(LocalUser? assistant) {
    AuthenticationService().deleteClientsData(
      uid: assistant?.uid ?? "",
      voidCallBack: (_) {
        //  getData();
      },
    );
  }

  AssistantViewModel();
}
