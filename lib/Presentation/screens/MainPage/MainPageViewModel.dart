// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import '../../../index/index_main.dart';

class MainPageViewModel extends GetxController {
  // ============================================================
  // 🧠 CURRENT USER
  // ============================================================

  BaseUser? get _user => Get.find<UserSession>().user?.user;

  UserType? get userType => _user?.userType;

  // ============================================================
  // 🎭 ROLES
  // ============================================================

  bool get isDoctor => userType == UserType.doctor;

  bool get isPatient => userType == UserType.patient;

  bool get isAssistant => userType == UserType.assistant;

  bool get isSales => userType == UserType.sales;

  bool get isPharmacy => userType == UserType.pharmacy;

  bool get isAdmin => userType == UserType.admin;

  // ============================================================
  // 🧩 SERVICES
  // ============================================================

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

    debugPrint("👤 user type is $userType");

    // 🔥 Start realtime listeners
    await _startClientsRealtime();
    await startReservationsRealtime();
    await _startNotificationsRealtime();
  }

  // ============================================================
  // 👤 LOAD CURRENT USER (ONLINE FIRST)
  // ============================================================

  Future<void> _loadCurrentUserFromOnline() async {
    try {
      final uid = _user?.uid;

      if (uid == null || uid.isEmpty) {
        debugPrint("❌ UID missing → skip online user load");
        return;
      }

      debugPrint("🌐 Loading current user from ONLINE...");

      await _authService.getClientsOnlineData(
        firebaseFilter: FirebaseFilter(
          orderBy: "token",
          equalTo: uid,
        ),
        voidCallBack: (users) {
          if (users.isEmpty) {
            debugPrint("❌ User not found online");
            return;
          }

          final user = users.first;

          if (user == null) return;

          // 🔥 update session (important)
          Get.find<UserSession>().setUser(user);

          debugPrint("✅ User loaded ONLINE → ${user.user.userType}");
        },
      );
    } catch (e) {
      debugPrint("❌ Error loading online user: $e");
    }
  }

  // ============================================================
  // 👥 CLIENTS REALTIME
  // ============================================================

  Future<void> _startClientsRealtime() async {
    debugPrint("🚀 GLOBAL Clients Realtime START");

    await _authService.startListening();

    debugPrint("✅ GLOBAL Clients Realtime RUNNING");
  }

  // ============================================================
  // 📅 RESERVATIONS REALTIME
  // ============================================================

  Future<void> startReservationsRealtime({String? doctorKey}) async {
    final user = _user;

    String? resolvedDoctorKey = doctorKey;

    // resolve if null
    if (resolvedDoctorKey == null || resolvedDoctorKey.isEmpty) {
      if (user is DoctorUser) {
        resolvedDoctorKey = user.uid;
      } else if (user is AssistantUser) {
        resolvedDoctorKey = user.doctorKey;
      }
    }

    if (resolvedDoctorKey == null || resolvedDoctorKey.isEmpty) {
      debugPrint("⚠️ No doctorKey → skip realtime reservations");
      return;
    }

    debugPrint("🚀 GLOBAL Reservations Realtime START → $resolvedDoctorKey");

    await _reservationService.startListening(
      doctorKey: resolvedDoctorKey,
    );

    debugPrint("✅ GLOBAL Reservations Realtime RUNNING → $resolvedDoctorKey");
  }

  // ============================================================
  // 🔔 NOTIFICATIONS REALTIME
  // ============================================================

  Future<void> _startNotificationsRealtime() async {
    final user = _user;

    String? clinicKey;

    if (user is AssistantUser) {
      clinicKey = user.clinicKey;
    }

    if (clinicKey == null || clinicKey.isEmpty) {
      debugPrint("⚠️ No clinicKey → skip notifications realtime");
      return;
    }

    debugPrint("🔔 GLOBAL Notifications Realtime START");

    await _notificationService.startListening();

    debugPrint("✅ GLOBAL Notifications Realtime RUNNING");
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  @override
  void onClose() {
    _reservationService.dispose();
    _authService.dispose();
    _notificationService.dispose();
    super.onClose();
  }
}