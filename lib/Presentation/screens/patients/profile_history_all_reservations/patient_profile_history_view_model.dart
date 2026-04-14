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

      // 1️⃣ Fetch Patient Info from LOCAL SQLite
      await AuthenticationService().getClientsData(
        query: SQLiteQueryParams(
          where: "key = ?",
          whereArgs: [patientKey],
          limit: 1,
        ),
        voidCallBack: (users) async {
          if (users.isEmpty || users.first == null) {
            Loader.dismiss();
            Loader.showError("لم يتم العثور على بيانات العميل");
            return;
          }

          patientModel = users.first!;

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
      query: SQLiteQueryParams(
        is_filtered: true,
        where: "patient_key = ?",
        whereArgs: [patientKey],
        orderBy: "created_at DESC",
      ),
      voidCallBack: (list) {
        reservations = list.whereType<ReservationModel>().toList();

        reservations.sort((a, b) {
          final aDate = a.createdAt ?? 0;
          final bDate = b.createdAt ?? 0;
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
