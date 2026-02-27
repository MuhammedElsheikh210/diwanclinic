import 'package:diwanclinic/Global/managers/location_manager.dart';
import 'package:intl/intl.dart';
import '../../../../../index/index_main.dart';

class VisitViewModel extends GetxController {
  /// 🔹 Original Data
  List<VisitModel?>? listVisits;

  /// 🔹 Filtered Data
  List<VisitModel?> filteredVisits = [];

  final LocationManager _locationManager = LocationManager();

  String get formattedSelectedDate => selectedDate == null
      ? "كل الزيارات"
      : DateFormat('dd/MM/yyyy').format(selectedDate!);

  /// ================= Dashboard Stats =================

  int get totalVisits => filteredVisits.length;

  int get completedVisits =>
      filteredVisits.where((v) => v?.visitStatus == "completed").length;

  int get pendingVisits =>
      filteredVisits.where((v) => v?.visitStatus != "completed").length;

  DateTime? selectedDate = DateTime.now();

  @override
  Future<void> onInit() async {
    selectedDate = DateTime.now();
    await getData();
    super.onInit();
  }

  /// ================= GET DATA =================
  Future<void> getData() async {
    VisitService().getVisitsData(
      data: {},
      query: SQLiteQueryParams(
        where: "status = ?",
        whereArgs: [1],
        is_filtered: true,
      ),
      firebaseFilter: FirebaseFilter(),
      voidCallBack: (data) {
        listVisits = data;
        _applyFilter();
      },
    );
  }

  /// ================= FILTER CONTROL =================

  /// 🔵 Change Specific Date
  void changeDate(DateTime date) {
    selectedDate = date;
    _applyFilter();
  }

  /// 🔵 Show All Visits
  void showAllVisits() {
    selectedDate = null;
    _applyFilter();
  }

  /// 🔵 Apply Filter Logic
  void _applyFilter() {
    if (listVisits == null) return;

    if (selectedDate == null) {
      /// ✅ Show All
      filteredVisits = List.from(listVisits!);
    } else {
      final formatted = DateFormat('yyyy-MM-dd').format(selectedDate!);

      filteredVisits = listVisits!
          .where((v) => v?.visitDate == formatted)
          .toList();
    }

    update();
  }

  /// ================= UPDATE STATUS =================
  void updateVisitStatus({
    required VisitModel visit,
    required String status,
    String? reason,
  }) {
    final updated = visit.copyWith(
      visitStatus: status,
      notCompletedReason: status == "not_completed" ? reason : null,
    );

    VisitService().updateVisitData(
      visit: updated,
      voidCallBack: (_) {
        Loader.dismiss();
        getData();
      },
    );
  }

  /// ================= DELETE =================
  void deleteVisit(VisitModel visit) {
    VisitService().deleteVisitData(
      visitKey: visit.key ?? "",
      voidCallBack: (_) {
        getData();
        Loader.showSuccess("تم حذف الزيارة");
      },
    );
  }

  /// ================= CHECK IN =================
  Future<void> checkInDoctor(VisitModel visit) async {
    Loader.show();

    final userLocation = await _locationManager.getLatLng();
    if (userLocation == null) {
      Loader.dismiss();
      Loader.showError("تعذر الحصول على الموقع");
      return;
    }

    final updatedVisit = visit.copyWith(
      doctorLat: userLocation['lat'],
      doctorLng: userLocation['lng'],
      checkInLat: userLocation['lat'],
      checkInLng: userLocation['lng'],
      checkInTimestamp: DateTime.now().millisecondsSinceEpoch,
    );

    VisitService().updateVisitData(
      visit: updatedVisit,
      voidCallBack: (_) {
        Loader.dismiss();
        Loader.showSuccess("تم تحديد موقع العيادة وتسجيل الوصول");
        getData();
      },
    );
  }
}
