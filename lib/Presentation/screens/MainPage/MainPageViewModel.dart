// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:diwanclinic/Presentation/parentControllers/patientReservationService.dart';

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
  final PatientReservationService _patientReservationService =
      PatientReservationService();

  final AuthenticationService _authService = AuthenticationService();
  final NotificationPatentService _notificationService =
      NotificationPatentService();

  // ============================================================
  // 🚀 INIT
  // ============================================================

  @override
  Future<void> onInit() async {
    super.onInit();

    if (!isPatient) {
      await _loadCurrentUserFromOnline();
      await _startClientsRealtime();
    }

    await startReservationsRealtime();
    await _startNotificationsRealtime();

  }

  // ============================================================
  // 🧪 DEBUG
  // ============================================================


  // ============================================================
  // 👤 LOAD CURRENT USER (ONLINE FIRST)
  // ============================================================

  Future<void> _loadCurrentUserFromOnline() async {
    try {
      final uid = _user?.uid;

      if (uid == null || uid.isEmpty) {
        return;
      }

      await _authService.getClientsOnlineData(
        firebaseFilter: FirebaseFilter(orderBy: "uid", equalTo: uid),
        voidCallBack: (users) {
          if (users.isEmpty) {
            return;
          }

          final user = users.first;
          if (user == null) return;

          Get.find<UserSession>().setUser(user);
        },
      );
    } catch (e) {
      
    }
  }

  // ============================================================
  // 👥 CLIENTS REALTIME
  // ============================================================

  Future<void> _startClientsRealtime() async {
    await _authService.startListening();
  }

  // ============================================================
  // 📅 RESERVATIONS REALTIME (🔥 UPDATED)
  // ============================================================

  Future<void> startReservationsRealtime({String? doctorKey}) async {
    final user = _user;
    AppLogger.info("user info", user?.userType?.name ?? "");

    // ============================================================
    // 👤 PATIENT FLOW
    // ============================================================
    if (isPatient) {
      final patientUid = user?.uid;

      if (patientUid == null || patientUid.isEmpty) {
        return;
      }

      await _patientReservationService.startListening(patientUid: patientUid);

      return;
    }

    // ============================================================
    // 🧑‍⚕️ DOCTOR / ASSISTANT FLOW
    // ============================================================

    String? resolvedDoctorKey = doctorKey;

    if (resolvedDoctorKey == null || resolvedDoctorKey.isEmpty) {
      if (user is DoctorUser) {
        resolvedDoctorKey = user.uid;
      } else if (user is AssistantUser) {
        resolvedDoctorKey = user.doctorKey;
      }
    }

    if (resolvedDoctorKey == null || resolvedDoctorKey.isEmpty) {
      return;
    }

    await _reservationService.startListening(doctorKey: resolvedDoctorKey);
  }

  // ============================================================
  // 🔔 NOTIFICATIONS REALTIME
  // ============================================================

  Future<void> _startNotificationsRealtime() async {
    final user = _user;

    // String? clinicKey;
    //
    // if (user is AssistantUser) {
    //   clinicKey = user.clinicKey;
    // }
    //
    // if (clinicKey == null || clinicKey.isEmpty) {
    //   
    //   return;
    // }

    await _notificationService.startListening();
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  @override
  void onClose() {
    _reservationService.dispose();
    _patientReservationService.dispose(); // 🔥 مهم جدًا
    _authService.dispose();
    super.onClose();
  }
}
