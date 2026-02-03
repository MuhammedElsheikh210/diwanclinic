import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class DoctorReviewRepository {
  /// 🔹 Get all doctor reviews
  Future<Either<AppError, List<DoctorReviewModel?>>> getDoctorReviewsDomain(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );

  /// 🔹 Get reviews from a specific patient for a given doctor
  Future<Either<AppError, List<DoctorReviewModel?>>>
  getDoctorReviewsFromPatientDomain(
    Map<String, dynamic> data,
    String? doctorKey,
  );

  /// 🔹 Add a doctor review (doctor/admin)
  Future<Either<AppError, SuccessModel>> addDoctorReviewDomain(
    Map<String, dynamic> data,
    String key,
  );

  // ✅ NEW: Add review from patient
  Future<Either<AppError, SuccessModel>> addDoctorFromPatientReviewDomain(
    Map<String, dynamic> data,
    String doctorKey,
    String reviewKey,
  );

  /// 🔹 Delete a doctor review
  Future<Either<AppError, SuccessModel>> deleteDoctorReviewDomain(
    Map<String, dynamic> data,
    String key,
  );

  /// 🔹 Update a doctor review
  Future<Either<AppError, SuccessModel>> updateDoctorReviewDomain(
    Map<String, dynamic> data,
    String key,
  );
}
