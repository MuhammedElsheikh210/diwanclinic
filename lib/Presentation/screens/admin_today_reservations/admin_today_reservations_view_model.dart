import 'package:intl/intl.dart';

import '../../../index/index_main.dart';

class AdminTodayReservationsViewModel extends GetxController {
  // ============================================================
  // State
  // ============================================================

  bool isLoadingDoctors = true;
  bool isLoadingReservations = false;

  List<LocalUser> _doctors = [];
  LocalUser? selectedDoctor;
  List<ReservationModel> reservations = [];

  // ============================================================
  // Computed
  // ============================================================

  List<LocalUser> get doctors => _doctors;

  String get _todayDate => DateFormat('dd-MM-yyyy').format(DateTime.now());

  String get todayLabel => DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now());

  int get completedCount => reservations
      .where((r) => r.status == ReservationStatus.completed.value)
      .length;

  int get inProgressCount => reservations
      .where((r) => r.status == ReservationStatus.inProgress.value)
      .length;

  int get pendingCount => reservations
      .where((r) => r.status == ReservationStatus.approved.value)
      .length;

  int get cancelledCount => reservations
      .where(
        (r) =>
            r.status == ReservationStatus.cancelledByUser.value ||
            r.status == ReservationStatus.cancelledByAssistant.value ||
            r.status == ReservationStatus.cancelledByDoctor.value,
      )
      .length;

  // ============================================================
  // Lifecycle
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    _loadDoctors();
  }

  // ============================================================
  // Load Doctors
  // ============================================================

  void _loadDoctors() {
    AuthenticationService().getClientsOnlineData(
      firebaseFilter: FirebaseFilter(orderBy: 'userType', equalTo: 'doctor'),
      voidCallBack: (users) {
        _doctors = users;
        isLoadingDoctors = false;
        update();
      },
    );
  }

  // ============================================================
  // Select Doctor
  // ============================================================

  void selectDoctor(LocalUser? doctor) {
    selectedDoctor = doctor;
    reservations = [];
    if (doctor != null) {
      _loadReservations();
    }
    update();
  }

  // ============================================================
  // Load Reservations
  // ============================================================

  void _loadReservations() {
    if (selectedDoctor == null) return;

    isLoadingReservations = true;
    update();

    final doctorUid = selectedDoctor!.uid ?? '';

    ReservationService().getReservationsData(
      query: SQLiteQueryParams(
        is_filtered: true,
        where: "doctor_uid = ? AND appointment_date_time = ?",
        whereArgs: [doctorUid, _todayDate],
        orderBy: "order_num ASC",
      ),
      voidCallBack: (list) {
        reservations = list.whereType<ReservationModel>().toList();
        isLoadingReservations = false;
        update();
      },
    );
  }

  void reloadCurrent() {
    if (selectedDoctor != null) {
      _loadReservations();
    }
  }
}
