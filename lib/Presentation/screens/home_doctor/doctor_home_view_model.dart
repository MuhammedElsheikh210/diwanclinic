import 'package:intl/intl.dart';
import '../../../index/index_main.dart';

class DoctorHomeViewModel extends GetxController {
  // ─────────────────────────────────────────────
  // 🔹 Stats
  // ─────────────────────────────────────────────
  int totalCount = 0;
  int completedCount = 0;
  int pendingCount = 0;
  int inProgressCount = 0;
  double todayRevenue = 0.0;

  // ─────────────────────────────────────────────
  // 🔹 Current / Next Patient
  // ─────────────────────────────────────────────
  ReservationModel? currentPatient;
  ReservationModel? nextPatient;
  List<ReservationModel> approvedList = [];

  bool isLoading = true;

  // ─────────────────────────────────────────────
  // 🔹 Doctor Info
  // ─────────────────────────────────────────────
  DoctorUser? get doctorUser {
    final u = Get.find<UserSession>().user?.user;
    return u is DoctorUser ? u : null;
  }

  String get doctorName => doctorUser?.name ?? 'الدكتور';
  String get specializationName => doctorUser?.specializationName ?? '';
  String get profileImage => doctorUser?.profileImage ?? '';
  double get rating => doctorUser?.totalRate ?? 0.0;
  int get ratingCount => doctorUser?.numberOfRates ?? 0;

  String get _doctorKey => Get.find<UserSession>().user?.uid ?? '';

  String get todayFormatted {
    final now = DateTime.now();
    const days = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    return '${days[now.weekday - 1]}، ${now.day} / ${now.month} / ${now.year}';
  }

  // ─────────────────────────────────────────────
  // 🔹 Init
  // ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadTodayStats();
  }

  // ─────────────────────────────────────────────
  // 🔹 Load Today Stats from SQLite
  // ─────────────────────────────────────────────
  void loadTodayStats() {
    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final key = _doctorKey;

    if (key.isEmpty) {
      isLoading = false;
      update();
      return;
    }

    isLoading = true;
    update();

    ReservationService().getReservationsData(
      query: SQLiteQueryParams(
        is_filtered: true,
        where: 'appointment_date_time = ? AND doctor_uid = ?',
        whereArgs: [today, key],
      ),
      voidCallBack: (list) {
        final all = list.whereType<ReservationModel>().toList();

        completedCount = all
            .where((r) => r.status == ReservationStatus.completed.value)
            .length;

        pendingCount = all
            .where((r) => r.status == ReservationStatus.approved.value)
            .length;

        inProgressCount = all
            .where((r) => r.status == ReservationStatus.inProgress.value)
            .length;

        totalCount = completedCount + pendingCount + inProgressCount;

        todayRevenue = all
            .where((r) => r.status == ReservationStatus.completed.value)
            .fold(
              0.0,
              (acc, r) => acc + (double.tryParse(r.paidAmount ?? '0') ?? 0.0),
            );

        // Patient in the room right now
        currentPatient = all
            .where((r) => r.status == ReservationStatus.inProgress.value)
            .firstOrNull;

        // Next patient waiting (lowest orderNum)
        final approved = all
            .where((r) => r.status == ReservationStatus.approved.value)
            .toList()
          ..sort(
            (a, b) => (a.orderNum ?? 9999).compareTo(b.orderNum ?? 9999),
          );
        nextPatient = approved.firstOrNull;
        approvedList = approved;

        isLoading = false;
        update();
      },
    );
  }
}
