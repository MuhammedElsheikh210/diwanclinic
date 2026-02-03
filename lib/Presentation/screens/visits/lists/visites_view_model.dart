
import '../../../../../index/index_main.dart';

class VisitViewModel extends GetxController {
  List<VisitModel?>? listVisits;

  @override
  Future<void> onInit() async {
    getData();
    super.onInit();
  }

  /// ✅ Fetch Visits from API
  void getData() {
    VisitService().getVisitsData(
      data: {}, // you can pass filtering params here if needed
      query: SQLiteQueryParams(
        where: "status = ?",
        whereArgs: [1],
        // orderBy: 'create_at ${Strings.desc}',
        is_filtered: true,
      ),
      firebaseFilter: FirebaseFilter(),
      voidCallBack: (data) {
        listVisits = data;
        update();
      },
    );
  }

  /// ✅ Delete a Visit
  void deleteVisit(VisitModel visit) {
    VisitService().deleteVisitData(
      visitKey: visit.key ?? "",
      voidCallBack: (_) {
        getData();
      },
    );
  }
}
