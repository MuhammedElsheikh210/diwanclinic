// ignore_for_file: depend_on_referenced_packages
import '../../../index/index_main.dart';

class MainPageViewModel extends GetxController {
  UserType? userType;

  bool get isDoctor => userType == UserType.doctor;

  bool get isPatient => userType == UserType.patient;

  bool get isAssistant => userType == UserType.assistant;

  bool get isSales => userType == UserType.sales;

  bool get isPharmacy => userType == UserType.pharmacy;

  bool get isAdmin => userType == UserType.admin;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _fetchUserFromFirebase();
  }

  Future<void> _fetchUserFromFirebase() async {
    try {
      //   Loader.show();

      // 🔹 Get logged-in user's UID stored locally
      final uid = LocalUser().getUserData().uid ?? "";
      if (uid.isEmpty) {
        Loader.showError("No logged-in user found");
        Loader.dismiss();
        return;
      }

      // 🔥 LOCAL ONLY: load user from SQLite
      await AuthenticationService().getClientsLocalData(
        isFiltered: false, // local-only mode
        query: SQLiteQueryParams(
          is_filtered: false,
          where: "token = ?", // user UID saved as `token`
          whereArgs: [uid],
          limit: 1,
        ),
        voidCallBack: (List<LocalUser?> users) async {
          Loader.dismiss();

          if (users.isEmpty) {
            print("⚠️ No user found locally with UID: $uid");
            userType = null;
          } else {
            final user = users.first!;
            userType = user.userType;
            print("📘 Loaded user from LOCAL database is ${user.toJson()}");

            // Optional: ensure sync consistency
            user.saveLocal(saveCallback: () {});
          }

          update();
        },
      );
    } catch (e) {
      Loader.dismiss();
      print("❌ Error in local user fetch: $e");
    }
  }
}
