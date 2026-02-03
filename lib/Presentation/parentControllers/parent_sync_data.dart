import 'package:diwanclinic/Data/Models/User_local/save_local_user.dart';
import 'package:intl/intl.dart';
import '../../index/index_main.dart';

class ParentSyncService extends GetxController {
  final TransactionService transactionService = TransactionService();
  final CategoryService categoryService = CategoryService();
  final SyncService syncService = SyncService();

  // 🆕 New Services
  final ClinicService clinicService = ClinicService();
  final DoctorService doctorService = DoctorService();
  final AssistantService assistantService = AssistantService();
  final AuthenticationService clientService = AuthenticationService();
  final ReservationService reservationService = ReservationService();
  final FilesService filesService = FilesService();
  final TransferService transferService = TransferService();
  final ShiftService shiftService = ShiftService();

  String get uid => LocalUser().getUserData().uid ?? "";

  String? get userType => LocalUser().getUserData().userType?.name;

  RxDouble progress = 0.0.obs;

  Future<void> syncAllData({
    required Function(ResponseStatus) voidCallBack,
  }) async {
    try {
      final int totalSteps = (userType == Strings.assistant)
          ? 4 // 🆕 +1 step (reservations_order)
          : (userType == Strings.doctor)
          ? 4 // clients + clinics + reservations + orders
          : 2;

      double incrementValue = 1 / totalSteps;

      // ===========================================
      // DOCTOR SYNC
      // ===========================================
      if (userType == Strings.doctor) {
        final user = LocalUser().getUserData();
        final String? doctorKey = user.uid;

        if (doctorKey == null) {
          print("Doctor UID is null");
          return;
        }

        final today = DateFormat('dd/MM/yyyy').format(DateTime.now());

        // 🔥 STEP 2) NORMAL RESERVATIONS
        await reservationService.getReservationsData(
          data: FirebaseFilter(),
          date: today,
          fromOnline: true,
          query: SQLiteQueryParams(
            is_filtered: true,
            where: "doctor_key = ? AND appointment_date_time = ?",
            whereArgs: [doctorKey, today],
          ),
          voidCallBack: (reservations) async {
            progress.value += incrementValue;
          },
        );

        // 🔥 STEP 3) Clinics
        await clinicService.getClinicsData(
          data: {},
          query: SQLiteQueryParams(is_filtered: true),
          fromOnline: true,
          isFiltered: true,
          voidCallBack: (_) async {
            progress.value += incrementValue;
          },
          filrebaseFilter: FirebaseFilter(),
        );

        // 🔥 STEP 4) Clients
        await clientService.getClientsData(
          query: SQLiteQueryParams(
            is_filtered: true,
            where: "doctor_key = ?",
            whereArgs: [doctorKey],
          ),
          isFiltered: true,
          voidCallBack: (_) async {
            progress.value += incrementValue;
          },
        );
      }
      // ===========================================
      // ASSISTANT SYNC
      // ===========================================
      else if (userType == Strings.assistant) {
        final user = LocalUser().getUserData();
        final String? clinicKey = user.clinicKey;
        final String? doctorKey = user.doctorKey;

        if (clinicKey == null || doctorKey == null) return;

        final today = DateFormat('dd/MM/yyyy').format(DateTime.now());

        // 🔥 STEP 2) RESERVATIONS
        await reservationService.getReservationsData(
          data: FirebaseFilter(),
          date: today,
          fromOnline: true,
          query: SQLiteQueryParams(
            is_filtered: true,
            where: "doctor_key = ? AND appointment_date_time = ?",
            whereArgs: [doctorKey, today],
          ),
          voidCallBack: (_) async {
            progress.value += incrementValue;
          },
        );

        // 🔥 STEP 3) CLINIC
        await clinicService.getClinicsData(
          data: {},
          query: SQLiteQueryParams(
            is_filtered: false,
            where: "key = ?",
            whereArgs: [clinicKey],
          ),
          fromOnline: true,
          isFiltered: false,
          voidCallBack: (_) async {
            progress.value += incrementValue;
          },
          filrebaseFilter: FirebaseFilter(orderBy: "key", equalTo: clinicKey),
        );

        // 🔥 STEP 4) CLIENTS
        await clientService.getClientsData(
          query: SQLiteQueryParams(is_filtered: false),
          isFiltered: false,
          voidCallBack: (_) async {
            progress.value += incrementValue;
          },
        );
      }

      voidCallBack(ResponseStatus.success);
    } catch (e) {
      Loader.showError("Sync Failed: $e");
      voidCallBack(ResponseStatus.error);
    }
  }
}
