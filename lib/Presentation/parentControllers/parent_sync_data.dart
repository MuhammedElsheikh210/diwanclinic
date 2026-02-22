import 'package:diwanclinic/Data/Models/User_local/save_local_user.dart';
import 'package:intl/intl.dart';
import '../../index/index_main.dart';

class ParentSyncService extends GetxController {
  final ClinicService clinicService = ClinicService();
  final AuthenticationService clientService = AuthenticationService();
  final ReservationService reservationService = ReservationService();
  final ShiftService shiftService = ShiftService();

  String get uid => LocalUser().getUserData().uid ?? "";

  String? get userType => LocalUser().getUserData().userType?.name;

  RxDouble progress = 0.0.obs;

  Future<void> syncAllData({
    required Function(ResponseStatus) voidCallBack,
  }) async {
    try {
      progress.value = 0.0;

      final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
      final user = LocalUser().getUserData();

      if (userType == null) {
        voidCallBack(ResponseStatus.error);
        return;
      }

      // عدد الخطوات حسب نوع المستخدم
      final int totalSteps = 4;
      final double increment = 1 / totalSteps;

      // =====================================================
      // 🔵 DOCTOR SYNC
      // =====================================================
      if (userType == Strings.doctor) {
        final doctorKey = uid;
        if (doctorKey.isEmpty) {
          voidCallBack(ResponseStatus.error);
          return;
        }

        print("🔵 Starting Doctor Online Sync");

        // 1️⃣ CLINICS
        await clinicService.getClinicsData(
          data: {},
          filrebaseFilter: FirebaseFilter(),
          isFiltered: false,
          query: SQLiteQueryParams(),
          voidCallBack: (_) => progress.value += increment,
        );

        // 2️⃣ SHIFTS
        await shiftService.getShiftsData(
          data: FirebaseFilter(orderBy: "clinicKey"),
          isFiltered: false,

          query: SQLiteQueryParams(),
          voidCallBack: (_) => progress.value += increment,
        );

        // 3️⃣ RESERVATIONS (Today)
        await reservationService.getReservationsData(
          date: today,
          data: FirebaseFilter(),
          query: SQLiteQueryParams(),
          voidCallBack: (_) => progress.value += increment,
        );

        // 4️⃣ CLIENTS
        await clientService.getClientsData(
          isFiltered: false,
          query: SQLiteQueryParams(),
          voidCallBack: (_) => progress.value += increment,
        );
      }
      // =====================================================
      // 🟢 ASSISTANT SYNC
      // =====================================================
      else if (userType == Strings.assistant) {
        final clinicKey = user.clinicKey;
        final doctorKey = user.doctorKey;

        if (clinicKey == null || doctorKey == null) {
          voidCallBack(ResponseStatus.error);
          return;
        }

        print("🟢 Starting Assistant Online Sync");

        // 1️⃣ CLINIC (Single)
        await clinicService.getClinicsData(
          data: {},
          filrebaseFilter: FirebaseFilter(orderBy: "key", equalTo: clinicKey),
          isFiltered: false,
          query: SQLiteQueryParams(),
          voidCallBack: (_) => progress.value += increment,
        );

        // 2️⃣ SHIFTS (Clinic Only)
        await shiftService.getShiftsData(
          data: FirebaseFilter(orderBy: "clinicKey", equalTo: clinicKey),
          query: SQLiteQueryParams(),
          isFiltered: false,

          voidCallBack: (_) => progress.value += increment,
        );

        // 3️⃣ RESERVATIONS (Today)
        await reservationService.getReservationsData(
          date: today,
          data: FirebaseFilter(),
          query: SQLiteQueryParams(),
          voidCallBack: (_) => progress.value += increment,
        );

        // 4️⃣ CLIENTS
        await clientService.getClientsData(
          isFiltered: false,
          query: SQLiteQueryParams(),
          voidCallBack: (_) => progress.value += increment,
        );
      }

      progress.value = 1.0;
      print("✅ Online Sync Completed");

      voidCallBack(ResponseStatus.success);
    } catch (e, stack) {
      print("❌ Sync Error: $e");
      print(stack);
      Loader.showError("Sync Failed: $e");
      voidCallBack(ResponseStatus.error);
    }
  }
}
