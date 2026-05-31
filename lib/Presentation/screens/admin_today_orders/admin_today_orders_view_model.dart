import 'package:intl/intl.dart';

import '../../../index/index_main.dart';

class AdminTodayOrdersViewModel extends GetxController {
  // ============================================================
  // State
  // ============================================================

  bool isLoadingDoctors = true;
  bool isLoadingOrders = false;

  List<LocalUser> _doctors = [];
  LocalUser? selectedDoctor;
  List<OrderModel> orders = [];

  // ============================================================
  // Computed
  // ============================================================

  List<LocalUser> get doctors => _doctors;

  String get todayLabel =>
      DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now());

  static const _finishedStatuses = {'delivered', 'completed', 'cancelled'};

  List<OrderModel> get activeOrders =>
      orders.where((o) => !_finishedStatuses.contains(o.status)).toList();

  List<OrderModel> get finishedOrders =>
      orders.where((o) => _finishedStatuses.contains(o.status)).toList();

  int _startOfDay() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
  }

  int _endOfDay() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59)
        .millisecondsSinceEpoch;
  }

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
    orders = [];
    if (doctor != null) {
      _loadOrders();
    }
    update();
  }

  // ============================================================
  // Load Orders
  // ============================================================

  void _loadOrders() {
    if (selectedDoctor == null) return;

    isLoadingOrders = true;
    update();

    OrderService().getOrdersData(
      data: {},
      filrebaseFilter: FirebaseFilter(
        orderBy: 'created_at',
        startAt: _startOfDay(),
        endAt: _endOfDay(),
      ),
      isFiltered: true,
      voidCallBack: (list) {
        final doctorUid = selectedDoctor!.uid ?? '';
        orders = list
            .whereType<OrderModel>()
            .where((o) => o.doctorKey == doctorUid)
            .toList()
          ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
        isLoadingOrders = false;
        update();
      },
    );
  }

  void reloadCurrent() {
    if (selectedDoctor != null) {
      _loadOrders();
    }
  }
}
