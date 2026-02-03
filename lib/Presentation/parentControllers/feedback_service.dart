// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class DoctorReviewService {
  final DoctorReviewUseCases useCase = initController(
        () => DoctorReviewUseCases(Get.find()),
  );

  /// 🔹 Add a new doctor review (doctor / admin)
  Future<void> addDoctorReviewData({
    required DoctorReviewModel review,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.addDoctorReview(review);
    result.fold(
          (l) {
        Loader.showError("Failed to add review");
        voidCallBack(ResponseStatus.error);
      },
          (r) {
        Loader.dismiss();
        voidCallBack(ResponseStatus.success);
      },
    );
  }

  /// ✅ Add a new doctor review FROM PATIENT
  Future<void> addDoctorFromPatientReviewData({
    required DoctorReviewModel review,
    required String doctorKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    if (doctorKey.isEmpty) {
      Loader.showError("Doctor key is missing");
      voidCallBack(ResponseStatus.error);
      return;
    }

    Loader.show();

    final result =
    await useCase.addDoctorFromPatientReview(review, doctorKey);

    result.fold(
          (l) {
        Loader.showError("Failed to add patient review");
        voidCallBack(ResponseStatus.error);
      },
          (r) {
        Loader.dismiss();
        voidCallBack(ResponseStatus.success);
      },
    );
  }

  /// 🔹 Update an existing doctor review
  Future<void> updateDoctorReviewData({
    required DoctorReviewModel review,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.updateDoctorReview(review);
    result.fold(
          (l) {
        Loader.showError("Failed to update review");
        voidCallBack(ResponseStatus.error);
      },
          (r) {
        Loader.dismiss();
        voidCallBack(ResponseStatus.success);
      },
    );
  }

  /// 🔹 Delete a doctor review
  Future<void> deleteDoctorReviewData({
    required String reviewKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.deleteDoctorReview(reviewKey);
    result.fold(
          (l) {
        Loader.showError("Failed to delete review");
        voidCallBack(ResponseStatus.error);
      },
          (r) {
        Loader.dismiss();
        voidCallBack(ResponseStatus.success);
      },
    );
  }

  /// 🔹 Get all reviews (general fetch)
  Future<void> getDoctorReviewsData({
    required Map<String, dynamic> data,
    required SQLiteQueryParams query,
    bool? isFiltered,
    required Function(List<DoctorReviewModel?>) voidCallBack,
  }) async {
    final result = await useCase.getDoctorReviews(data, query, isFiltered);
    result.fold(
          (l) =>
          Loader.showError("Something went wrong while fetching reviews"),
          (r) => voidCallBack(r),
    );
  }

  /// 🔹 Get reviews for a specific doctor (from a specific patient)
  Future<void> getDoctorReviewsFromPatientData({
    required Map<String, dynamic> data,
    required String? doctorKey,
    required Function(List<DoctorReviewModel?>) voidCallBack,
  }) async {
    final result =
    await useCase.getDoctorReviewsFromPatient(data, doctorKey);
    result.fold(
          (l) => Loader.showError(
        "Something went wrong while fetching patient reviews",
      ),
          (r) => voidCallBack(r),
    );
  }
}
