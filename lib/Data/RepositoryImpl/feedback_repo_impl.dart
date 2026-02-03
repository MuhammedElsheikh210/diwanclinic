import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class DoctorReviewRepositoryImpl extends DoctorReviewRepository {
  final DoctorReviewDataSourceRepo _doctorReviewDataSourceRepo;

  DoctorReviewRepositoryImpl(this._doctorReviewDataSourceRepo);

  /// 🔹 Get all doctor reviews
  @override
  Future<Either<AppError, List<DoctorReviewModel?>>> getDoctorReviewsDomain(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      final result = await _doctorReviewDataSourceRepo.getDoctorReviews(
        data,
        query,
        isFiltered,
      );
      return Right(result);
    } catch (e, s) {
      debugPrint('❌ [getDoctorReviewsDomain] Error: $e\n$s');
      return Left(AppError(e.toString()));
    }
  }

  /// 🔹 Get reviews by patient for a specific doctor
  @override
  Future<Either<AppError, List<DoctorReviewModel?>>>
  getDoctorReviewsFromPatientDomain(
    Map<String, dynamic> data,
    String? doctorKey,
  ) async {
    try {
      final result = await _doctorReviewDataSourceRepo
          .getDoctorReviewsFromPatient(data, doctorKey);
      return Right(result);
    } catch (e, s) {
      debugPrint('❌ [getDoctorReviewsFromPatientDomain] Error: $e\n$s');
      return Left(AppError(e.toString()));
    }
  }

  /// 🔹 Add a new review (doctor / admin)
  @override
  Future<Either<AppError, SuccessModel>> addDoctorReviewDomain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _doctorReviewDataSourceRepo.addDoctorReview(
        data,
        key,
      );
      return Right(result);
    } catch (e, s) {
      debugPrint('❌ [addDoctorReviewDomain] Error: $e\n$s');
      return Left(AppError(e.toString()));
    }
  }

  /// ✅ Add a new review from patient
  @override
  Future<Either<AppError, SuccessModel>> addDoctorFromPatientReviewDomain(
    Map<String, dynamic> data,
    String doctorKey,
    String reviewKey,
  ) async {
    try {
      final result = await _doctorReviewDataSourceRepo
          .addDoctorFromPatientReview(data, doctorKey, reviewKey);
      return Right(result);
    } catch (e, s) {
      debugPrint('❌ [addDoctorFromPatientReviewDomain] Error: $e\n$s');
      return Left(AppError(e.toString()));
    }
  }

  /// 🔹 Delete an existing review
  @override
  Future<Either<AppError, SuccessModel>> deleteDoctorReviewDomain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _doctorReviewDataSourceRepo.deleteDoctorReview(
        data,
        key,
      );
      return Right(result);
    } catch (e, s) {
      debugPrint('❌ [deleteDoctorReviewDomain] Error: $e\n$s');
      return Left(AppError(e.toString()));
    }
  }

  /// 🔹 Update a review
  @override
  Future<Either<AppError, SuccessModel>> updateDoctorReviewDomain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _doctorReviewDataSourceRepo.updateDoctorReview(
        data,
        key,
      );
      return Right(result);
    } catch (e, s) {
      debugPrint('❌ [updateDoctorReviewDomain] Error: $e\n$s');
      return Left(AppError(e.toString()));
    }
  }
}
