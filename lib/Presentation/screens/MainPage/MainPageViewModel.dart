import '../../../index/index_main.dart';

class MainPageViewModel extends GetxController {
  // ============================================================
  // 🧠 CURRENT USER
  // ============================================================

  int currentIndex = 0;

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

  // 🔥 NEW
  final PatientOrderService _patientOrderService = PatientOrderService();

  final AuthenticationService _authService = AuthenticationService();

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

    await startRealtime(); // 🔥 بدل القديمة
  }

  // ============================================================
  // 🔄 INDEX
  // ============================================================

  void changeIndex(int index) {
    currentIndex = index;
    update();
  }

  // ============================================================
  // 👤 LOAD CURRENT USER
  // ============================================================

  Future<void> _loadCurrentUserFromOnline() async {
    try {
      final uid = _user?.uid;

      if (uid == null || uid.isEmpty) return;

      await _authService.getClientsOnlineData(
        firebaseFilter: FirebaseFilter(orderBy: "uid", equalTo: uid),
        voidCallBack: (users) async {
          if (users.isEmpty) return;

          final user = users.first;
          if (user == null) return;

          Get.find<UserSession>().setUser(user);
        },
      );
    } catch (e) {}
  }

  // ============================================================
  // 👥 CLIENTS REALTIME
  // ============================================================

  Future<void> _startClientsRealtime() async {
    await _authService.startListening();
  }

  // ============================================================
  // 🔥 ALL REALTIME (Reservation + Orders)
  // ============================================================

  Future<void> startRealtime({String? doctorKey}) async {
    final user = _user;

    // ============================================================
    // 👤 PATIENT FLOW
    // ============================================================

    if (isPatient) {
      final patientUid = user?.uid;

      if (patientUid == null || patientUid.isEmpty) {
        return;
      }

      // =======================
      // 📅 RESERVATIONS
      // =======================

      _patientReservationService.onReservationAdded = (reservation) {
        final reservationVM = Get.find<ReservationPatientViewModel>();
        reservationVM.updateList(reservation);
      };

      _patientReservationService.onReservationUpdated = (reservation) {
        final reservationVM = Get.find<ReservationPatientViewModel>();
        reservationVM.updateList(reservation);
      };

      _patientReservationService.onReservationRemoved = (key) {
        final reservationVM = Get.find<ReservationPatientViewModel>();
        reservationVM.listReservations?.removeWhere((e) => e?.key == key);
        reservationVM.update();
      };

      await _patientReservationService.startListening(patientUid: patientUid);

      // =======================
      // 🛒 ORDERS (🔥 FIXED FINAL)
      // =======================

      _patientOrderService.onOrderAdded = (order) {
        // 🔥 Home
        final home = Get.find<HomePatientController>();
        home.upsertOrder(order);

        // 🔥 Orders List Screen
        if (Get.isRegistered<OrdersListViewModel>()) {
          Get.find<OrdersListViewModel>().upsertOrder(order);
        } else {}
      };

      _patientOrderService.onOrderUpdated = (order) {
        debugPrint('[ORDER_SYNC] MainPageVM.onOrderUpdated → key=${order.key} status=${order.status}');
        final home = Get.find<HomePatientController>();
        home.upsertOrder(order);

        final isRegistered = Get.isRegistered<OrdersListViewModel>();
        debugPrint('[ORDER_SYNC] OrdersListViewModel registered=$isRegistered');
        if (isRegistered) {
          Get.find<OrdersListViewModel>().upsertOrder(order);
        }
      };

      _patientOrderService.onOrderRemoved = (key) {
        // 🔥 Home
        final home = Get.find<HomePatientController>();
        home.orders.removeWhere((o) => o.key == key);
        home.orders.refresh();
        home.update();

        // 🔥 Orders List Screen
        if (Get.isRegistered<OrdersListViewModel>()) {
          Get.find<OrdersListViewModel>().removeOrder(key);
        }
      };

      await _patientOrderService.startListening(patientUid: patientUid);

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

    final today = AppDateFormatter.toDash(null); // today in dd-MM-yyyy
    await _reservationService.startListening(
      doctorKey: resolvedDoctorKey,
      date: today,
    );
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  @override
  void onClose() {
    _reservationService.dispose();
    _patientReservationService.dispose();
    _patientOrderService.dispose();
    _authService.dispose();

    super.onClose();
  }
}
