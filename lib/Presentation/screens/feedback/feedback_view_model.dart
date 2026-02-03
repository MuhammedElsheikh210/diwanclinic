import 'package:diwanclinic/Presentation/parentControllers/feedback_service.dart';

import '../../../../../index/index_main.dart';

class DoctorFeedbackViewModel extends GetxController {
  List<DoctorReviewModel?>? listReviews;

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  void getData() {
    DoctorReviewService().getDoctorReviewsData(
      data: {},
      query: SQLiteQueryParams(is_filtered: true),
      voidCallBack: (data) {
        Loader.dismiss();
        listReviews = data;
        update();
      },
    );
    update();
  }
}
