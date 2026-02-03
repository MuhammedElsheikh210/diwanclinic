import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class DoctorReviewUseCases {
  final DoctorReviewRepository _repository;

  DoctorReviewUseCases(this._repository);

  /// 🔹 Add a new doctor review (doctor / admin)
  Future<Either<AppError, SuccessModel>> addDoctorReview(
    DoctorReviewModel review,
  ) {
    final key = review.path ?? const Uuid().v4();
    return _repository.addDoctorReviewDomain(review.toJson(), key);
  }

  /// ✅ Add a new doctor review FROM PATIENT
  Future<Either<AppError, SuccessModel>> addDoctorFromPatientReview(
    DoctorReviewModel review,
    String doctorKey,
  ) {
    if (doctorKey.isEmpty) {
      return Future.value(const Left(AppError("Doctor key is missing")));
    }

    return _repository.addDoctorFromPatientReviewDomain(
      review.toJson(),
      review.key ?? "",
      doctorKey,
    );
  }

  /// 🔹 Update an existing doctor review
  Future<Either<AppError, SuccessModel>> updateDoctorReview(
    DoctorReviewModel review,
  ) {
    final key = review.path ?? "";
    if (key.isEmpty) {
      return Future.value(const Left(AppError("Review key is missing")));
    }
    return _repository.updateDoctorReviewDomain(review.toJson(), key);
  }

  /// 🔹 Delete a doctor review by key
  Future<Either<AppError, SuccessModel>> deleteDoctorReview(String key) {
    if (key.isEmpty) {
      return Future.value(const Left(AppError("Review key is missing")));
    }
    return _repository.deleteDoctorReviewDomain({}, key);
  }

  /// 🔹 Get all doctor reviews
  Future<Either<AppError, List<DoctorReviewModel?>>> getDoctorReviews(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) {
    return _repository.getDoctorReviewsDomain(data, query, isFiltered);
  }

  /// 🔹 Get reviews from a specific patient for a specific doctor
  Future<Either<AppError, List<DoctorReviewModel?>>>
  getDoctorReviewsFromPatient(Map<String, dynamic> data, String? doctorKey) {
    return _repository.getDoctorReviewsFromPatientDomain(data, doctorKey);
  }
}
