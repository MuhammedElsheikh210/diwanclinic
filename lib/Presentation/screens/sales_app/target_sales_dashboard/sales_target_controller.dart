import '../../../../index/index_main.dart';

class SalesTargetController extends GetxController {
  List<VisitModel?> allVisits = [];
  Map<String, VisitModel> uniqueDoctors = {};

  int monthlyTarget = 52;
  double commissionPerDeal = 12.5;

  @override
  void onInit() {
    super.onInit();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    VisitService().getVisitsData(
      data: {},
      query: SQLiteQueryParams(),
      firebaseFilter: FirebaseFilter(),
      voidCallBack: (data) {
        allVisits = data;
        _groupDoctors();
        update();
      },
    );
  }

  void _groupDoctors() {
    uniqueDoctors.clear();

    for (var visit in allVisits) {
      if (visit == null) continue;

      /// 🔥 استخدم key مش الاسم
      final key = visit.key ?? visit.name ?? "";

      if (!uniqueDoctors.containsKey(key)) {
        uniqueDoctors[key] = visit;
      } else {
        final existing = uniqueDoctors[key]!;

        /// لو واحدة فيهم deal → خليه deal
        if (visit.doctorSalesStatus == "deal") {
          uniqueDoctors[key] = visit;
        } else if (existing.doctorSalesStatus != "deal") {
          /// لو مفيش deal ناخد الأحدث
          if ((visit.visitTimestamp ?? 0) > (existing.visitTimestamp ?? 0)) {
            uniqueDoctors[key] = visit;
          }
        }
      }
    }
  }

  /// ===========================
  /// 🎯 TARGET LOGIC
  /// ===========================

  List<VisitModel> get completedDoctors {
    return uniqueDoctors.values
        .where((v) => v.doctorSalesStatus == "deal")
        .toList();
  }

  int get completedCount => completedDoctors.length;

  int get remaining => monthlyTarget - completedCount;

  double get percentage =>
      completedCount == 0 ? 0 : completedCount / monthlyTarget;

  double get totalCommission => completedCount * commissionPerDeal;
}
