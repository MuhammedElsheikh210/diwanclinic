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

    final date = DateFormat('dd/MM/yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(dayTimestamp));

    _loadByDate(date);
  }

  // =====================================================
  // 🔥 Load today data
  // =====================================================
  void _loadTodayData() {
    final now = DateTime.now();
    todayDate = DateFormat('dd/MM/yyyy').format(now);
    _loadByDate(todayDate);
  }

  // =====================================================
  // 🔥 SINGLE loader (only completed)
  // =====================================================
  void _loadByDate(String date) {
    final doctorKey = LocalUser().getUserData().uid ?? "";

    final query = SQLiteQueryParams(
      is_filtered: true,
      where: """
        appointment_date_time = ?
        AND status = ?
        AND doctor_key = ?
      """,
      whereArgs: [
        date,
        ReservationStatus.completed.value, // ✅ واحد ثابت
        doctorKey,
      ],
    );

    ReservationService().getReservationsData(
      date: date,
      data: FirebaseFilter(orderBy: "status",equalTo: "completed"),
      query: query,
      voidCallBack: (list) {
        todayReservations = list.whereType<ReservationModel>().toList();
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
  bool _isNew(String? type) =>
      (type ?? "").contains("جديد");

  bool _isRevisit(String? type) {
    final t = (type ?? "").trim();
    return t.contains("إعادة") || t.contains("اعادة") || t.contains("إعاده");
  }

  bool _isUrgent(String? type) =>
      (type ?? "").contains("مستعجل");

  double _sum(List<ReservationModel> list) {
    return list.fold(
      0.0,
          (sum, r) => sum + (double.tryParse(r.paidAmount ?? "0") ?? 0),
    );
  }
}
