import 'package:diwanclinic/Presentation/parentControllers/visite_parent_demo.dart';

import '../../../../../index/index_main.dart';

class VisitViewModel extends GetxController {
  List<VisitModel?>? listVisits;

  @override
  Future<void> onInit() async {
    getData();

    super.onInit();
  }

  /// =========================
  /// GET DATA
  /// =========================
  void getData() {
    VisitParentService().getVisits(
      data: {},

      callBack: (data) {
        listVisits = data;

        update();
      },
    );
  }

  /// =========================
  /// DELETE
  /// =========================
  void deleteVisit(VisitModel visit) {
    VisitParentService().deleteVisit(
      id: visit.key ?? "",

      callBack: (_) {
        getData();
      },
    );
  }
}
