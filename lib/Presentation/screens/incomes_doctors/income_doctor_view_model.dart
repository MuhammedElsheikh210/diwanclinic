import 'package:diwanclinic/Global/Enums/reservation_status_new.dart';
import 'package:intl/intl.dart';
import '../../../../../index/index_main.dart';

class IncomeViewModel extends GetxController {
  List<ReservationModel> todayReservations = [];

  bool showDailyReport = false;

  int? selectedDay;
  String? selectedDayFormatted;

  double newTotal = 0;
  double reTotal = 0;
  double urgentTotal = 0;
  double dayTotal = 0;

  int newCount = 0;
  int reCount = 0;
  int urgentCount = 0;

  String todayDate = "";

  // 🔹 The date currently shown on screen (dd-MM-yyyy). Used to ignore stale
  // fetch responses if the user switches dates quickly.
  String _currentDate = "";

  @override
  void onInit() {
    super.onInit();
    _loadTodayData();
  }

  // =====================================================
  // 🔥 Load reservations for selected day (COMPLETED ONLY)
  // =====================================================
  void getDataByDay(int dayTimestamp, String formattedDay) {
    selectedDay = dayTimestamp;
    selectedDayFormatted = formattedDay;

    final date = DateFormat(
      'dd-MM-yyyy',
    ).format(DateTime.fromMillisecondsSinceEpoch(dayTimestamp));

    _loadByDate(date);
  }

  // =====================================================
  // 🔥 Load today data
  // =====================================================
  void _loadTodayData() {
    final now = DateTime.now();
    todayDate = DateFormat('dd-MM-yyyy').format(now);
    _loadByDate(todayDate);
  }

  // =====================================================
  // 🔥 SINGLE loader (only completed)
  // =====================================================
  // Reads the day directly from Firebase every time. The local realtime
  // listener only auto-syncs *today* into SQLite, so reading SQLite for past
  // days returned empty ("no income"). A one-shot remote fetch always returns
  // the correct data regardless of which date the SQLite cache holds.
  void _loadByDate(String date) {
    _currentDate = date;
    final doctorKey = Get.find<UserSession>().user?.uid ?? "";

    if (doctorKey.isEmpty) {
      todayReservations = [];
      _calculateTotals();
      update();
      return;
    }

    ReservationService().fetchReservationsOnce(
      doctorKey: doctorKey,
      date: AppDateFormatter.toDash(date),
      voidCallBack: (list) {
        // Ignore a late response for a date the user already navigated away from.
        if (_currentDate != date) return;

        todayReservations =
            list
                .where((r) => r.status == ReservationStatus.completed.value)
                .toList();
        _calculateTotals();
        update();
      },
    );
  }

  // =====================================================
  // 🔢 Totals & Counts (completed only by design)
  // =====================================================
  void _calculateTotals() {
    final newList =
        todayReservations.where((r) => _isNew(r.reservationType)).toList();

    final reList =
        todayReservations.where((r) => _isRevisit(r.reservationType)).toList();

    final urgentList =
        todayReservations.where((r) => _isUrgent(r.reservationType)).toList();

    newCount = newList.length;
    reCount = reList.length;
    urgentCount = urgentList.length;

    newTotal = _sum(newList);
    reTotal = _sum(reList);
    urgentTotal = _sum(urgentList);

    dayTotal = newTotal + reTotal + urgentTotal;
  }

  // =====================================================
  // 🧠 Helpers
  // =====================================================
  bool _isNew(String? type) => (type ?? "").contains("جديد");

  bool _isRevisit(String? type) {
    final t = (type ?? "").trim();
    return t.contains("إعادة") || t.contains("اعادة") || t.contains("إعاده");
  }

  bool _isUrgent(String? type) => (type ?? "").contains("مستعجل");

  double _sum(List<ReservationModel> list) {
    return list.fold(
      0.0,
      (sum, r) => sum + (double.tryParse(r.paidAmount ?? "0") ?? 0),
    );
  }
}
