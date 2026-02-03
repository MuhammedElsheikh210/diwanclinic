import '../../../../../index/index_main.dart';

class PatientProfileAllHistoryViewModel extends GetxController {
  // 🔹 Patient Info (FROM FIREBASE)
  LocalUser? patientModel;

  // 🔹 All Reservations (LOCAL)
  List<ReservationModel> reservations = [];

  // ─────────────────────────────────────────────
  // 📥 Fetch Patient (FIREBASE) + Reservations (LOCAL)
  // ─────────────────────────────────────────────
  Future<void> getData(String patientKey) async {
    try {
      Loader.show();

      // 1️⃣ Fetch Patient Info from Firebase ONLY
      await AuthenticationService().getSingleClientsData(
        filrebaseFilter: FirebaseFilter(orderBy: "key", equalTo: patientKey),
        voidCallBack: (user) async {
          if (user == null) {
            Loader.dismiss();
            Loader.showError("لم يتم العثور على بيانات العميل");
            return;
          }

          patientModel = user;

          // 2️⃣ Fetch local reservations for this patient
          await _loadLocalReservations(patientKey);

          Loader.dismiss();
          update();
        },
      );
    } catch (e) {
      Loader.dismiss();
      Loader.showError("حدث خطأ أثناء تحميل البيانات: $e");
    }
  }

  // ─────────────────────────────────────────────
  // 📡 Load Reservations from SQLite ONLY
  // ─────────────────────────────────────────────
  Future<void> _loadLocalReservations(String patientKey) async {
    await ReservationService().getReservationsData(
      date: null,
      data: FirebaseFilter(), // ignored (local)
      query: SQLiteQueryParams(
        is_filtered: true,
        where: "patient_key = ?",
        whereArgs: [patientKey],
        orderBy: "create_at DESC",
      ),
      voidCallBack: (list) {
        reservations = list.whereType<ReservationModel>().toList();

        reservations.sort((a, b) {
          final aDate = a.createAt ?? 0;
          final bDate = b.createAt ?? 0;
          return bDate.compareTo(aDate);
        });

        update();
      },
    );
  }

  // ─────────────────────────────────────────────
  // 🧹 Clear Data
  // ─────────────────────────────────────────────
  void clearData() {
    patientModel = null;
    reservations.clear();
    update();
  }
}
