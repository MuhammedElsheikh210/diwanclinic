import 'package:intl/intl.dart';
import '../../index/index_main.dart';

class ParentSyncService extends GetxController {
  final TransactionService transactionService = TransactionService();
  final CategoryService categoryService = CategoryService();
  final SyncService syncService = SyncService();

  // 🆕 Services
  final ClinicService clinicService = ClinicService();
  final DoctorService doctorService = DoctorService();
  final AssistantService assistantService = AssistantService();
  final AuthenticationService clientService = AuthenticationService();
  final ReservationService reservationService = ReservationService();
  final FilesService filesService = FilesService();
  final TransferService transferService = TransferService();
  final ShiftService shiftService = ShiftService();

  // ============================================================
  // 🧠 CURRENT USER
  // ============================================================

  BaseUser? get _user => Get.find<UserSession>().user?.user;

  UserType? get _userType => _user?.userType;

  String? get _uid => _user?.uid;

  // ============================================================
  // 📊 PROGRESS
  // ============================================================

  RxDouble progress = 0.0.obs;

  // ============================================================
  // 🚀 MAIN SYNC
  // ============================================================

  Future<void> syncAllData({
    required Function(ResponseStatus) voidCallBack,
  }) async {
    try {
      final user = _user;

      if (user == null) {
        throw Exception("❌ No logged in user");
      }

      final isDoctor = user.userType == UserType.doctor;
      final isAssistant = user.userType == UserType.assistant;

      final int totalSteps = isDoctor
          ? 4
          : isAssistant
          ? 4
          : 2;

      final double incrementValue = 1 / totalSteps;

      final today = DateFormat('dd-MM-yyyy').format(DateTime.now());

      // ============================================================
      // 👨‍⚕️ DOCTOR SYNC
      // ============================================================

      if (isDoctor) {
        final doctorKey = user.uid;

        if (doctorKey == null || doctorKey.isEmpty) {
          throw Exception("❌ Doctor UID is missing");
        }

        // 🔥 STEP: CLIENTS
        await clientService.getClientsData(
          query: SQLiteQueryParams(
            is_filtered: true,
            where: "doctor_key = ?",
            whereArgs: [doctorKey],
          ),
          voidCallBack: (_) {
            progress.value += incrementValue;
          },
        );
      }

      // ============================================================
      // 🧑‍⚕️ ASSISTANT SYNC
      // ============================================================

      else if (isAssistant) {
        if (user is! AssistantUser) {
          throw Exception("❌ Invalid assistant model");
        }

        final clinicKey = user.clinicKey;
        final doctorKey = user.doctorKey;

        if (clinicKey == null || doctorKey == null) {
          throw Exception("❌ Missing clinicKey or doctorKey");
        }

        // 🔥 STEP: CLIENTS
        await clientService.getClientsData(
          query: SQLiteQueryParams(is_filtered: false),
          voidCallBack: (_) {
            progress.value += incrementValue;
          },
        );
      }

      // ============================================================
      // ✅ DONE
      // ============================================================

      voidCallBack(ResponseStatus.success);
    } catch (e) {
      Loader.showError("Sync Failed: $e");
      voidCallBack(ResponseStatus.error);
    }
  }
}