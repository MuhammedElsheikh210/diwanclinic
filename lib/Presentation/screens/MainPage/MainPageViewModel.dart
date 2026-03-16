// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import '../../../index/index_main.dart';

class MainPageViewModel extends GetxController {
  UserType? userType;

  bool get isDoctor => userType == UserType.doctor;

  bool get isPatient => userType == UserType.patient;

  bool get isAssistant => userType == UserType.assistant;

  bool get isSales => userType == UserType.sales;

  bool get isPharmacy => userType == UserType.pharmacy;

  bool get isAdmin => userType == UserType.admin;

  final ReservationService _reservationService = ReservationService();
  final AuthenticationService _authService = AuthenticationService();
  final NotificationPatentService _notificationService =
      NotificationPatentService();

  // ============================================================
  // 🚀 INIT
  // ============================================================

  @override
  Future<void> onInit() async {
    super.onInit();

    await _loadCurrentUserFromOnline();
    print("user type is $userType");

    // 🔥 Start realtime listeners
    await _startClientsRealtime();
    await startReservationsRealtime();
    await _startNotificationsRealtime(); // 🔔 NEW
  }

  // ============================================================
  // 👤 LOAD CURRENT USER (ONLINE FIRST)
  // ============================================================

  Future<void> _loadCurrentUserFromOnline() async {
    try {
      final uid = LocalUser().getUserData().uid ?? "";
      if (uid.isEmpty) return;

      print("🌐 Loading current user from ONLINE...");

      await _authService.getClientsOnlineData(
        firebaseFilter: FirebaseFilter(orderBy: "token", equalTo: uid),
        voidCallBack: (users) {
          if (users.isEmpty) {
            print("❌ User not found online");
            return;
          }

          final user = users.first!;
          userType = user.userType;

          print("✅ User loaded ONLINE → ${user.userType}");
          print("✅ User clinicKey → ${user.clinicKey}");
          update();
        },
      );
    } catch (e) {
      print("❌ Error loading online user: $e");
    }
  }

  // ============================================================
  // 👥 CLIENTS REALTIME
  // ============================================================

  Future<void> _startClientsRealtime() async {
    print("🚀 GLOBAL Clients Realtime START");

    await _authService.startListening();

    print("✅ GLOBAL Clients Realtime RUNNING");
  }

  // ============================================================
  // 📅 RESERVATIONS REALTIME
  // ============================================================

  Future<void> startReservationsRealtime({String? doctorKey}) async {
    final key = doctorKey ?? LocalUser().getUserData().doctorKey ?? "";

    if (key.isEmpty) {
      print("⚠️ No doctorKey → skip realtime reservations");
      return;
    }

    print("🚀 GLOBAL Reservations Realtime START → $key");

    await _reservationService.startListening(doctorKey: key);

    print("✅ GLOBAL Reservations Realtime RUNNING → $key");
  }

  // ============================================================
  // 🔔 NOTIFICATIONS REALTIME (NEW)
  // ============================================================

  Future<void> _startNotificationsRealtime() async {
    final clinicKey = LocalUser().getUserData().clinicKey ?? "";
    if (clinicKey.isEmpty) return;

    print("🔔 GLOBAL Notifications Realtime START");

    await _notificationService.startListening();

    print("✅ GLOBAL Notifications Realtime RUNNING");
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  @override
  void onClose() {
    _reservationService.dispose();
    _authService.dispose();
    _notificationService.dispose(); // 🔔 NEW
    super.onClose();
  }
}
