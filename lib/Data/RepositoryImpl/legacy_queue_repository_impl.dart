import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class LegacyQueueRepositoryImpl extends LegacyQueueRepository {
  final LegacyQueueDataSourceRepo _dataSource;

  LegacyQueueRepositoryImpl(this._dataSource);

  // ------------------------------------------------------------
  // 🧾 Legacy Queue
  // ------------------------------------------------------------
  @override
  Future<Either<AppError, List<LegacyQueueModel?>>>
  getLegacyQueueByDateDomain(
      String date,
      Map<String, dynamic> data, {
        bool isPatient = false,
        String? doctorUid,
      }) async {
    try {
      final result = await _dataSource.getLegacyQueueByDate(
        date,
        data,
        isPatient: isPatient,
        doctorUid: doctorUid,
      );

      return Right(result);
    } catch (e, stackTrace) {
      debugPrint("❌ Repository Error (LegacyQueue): $e");
      return Left(AppError(e.toString()));
    }
  }

  // ------------------------------------------------------------
  // 🔒 Open / Close Days
  // ------------------------------------------------------------
  @override
  Future<Either<AppError, List<LegacyQueueModel?>>>
  getOpenCloseDaysByDateDomain(
      String date,
      Map<String, dynamic> data, {
        bool isPatient = false,
        String? doctorUid,
      }) async {
    try {
      final result = await _dataSource.getOpenCloseDaysByDate(
        date,
        data,
        isPatient: isPatient,
        doctorUid: doctorUid,
      );

      return Right(result);
    } catch (e) {
      debugPrint("❌ Repository Error (OpenClose): $e");
      return Left(AppError(e.toString()));
    }
  }

  // ------------------------------------------------------------
  // ➕ ADD
  // ------------------------------------------------------------
  @override
  Future<Either<AppError, SuccessModel>> addLegacyQueueDomain(
      String date,
      String key,
      Map<String, dynamic> data, {
        bool isPatient = false,
        String? doctorUid,
      }) async {
    try {
      final result = await _dataSource.addLegacyQueue(
        date,
        key,
        data,
        isPatient: isPatient,
        doctorUid: doctorUid,
      );

      return Right(result);
    } catch (e) {
      debugPrint("❌ Repository Error (Add): $e");
      return Left(AppError(e.toString()));
    }
  }

  // ------------------------------------------------------------
  // ✏️ UPDATE
  // ------------------------------------------------------------
  @override
  Future<Either<AppError, SuccessModel>> updateLegacyQueueDomain(
      String date,
      String key,
      Map<String, dynamic> data, {
        bool isPatient = false,
        String? doctorUid,
      }) async {
    try {
      final result = await _dataSource.updateLegacyQueue(
        date,
        key,
        data,
        isPatient: isPatient,
        doctorUid: doctorUid,
      );

      return Right(result);
    } catch (e) {
      debugPrint("❌ Repository Error (Update): $e");
      return Left(AppError(e.toString()));
    }
  }

  // ------------------------------------------------------------
  // 🗑 DELETE
  // ------------------------------------------------------------
  @override
  Future<Either<AppError, SuccessModel>> deleteLegacyQueueDomain(
      String date,
      String key, {
        bool isPatient = false,
        String? doctorUid,
        bool isOpenCloseFeature = false,
      }) async {
    try {
      final result = await _dataSource.deleteLegacyQueue(
        date,
        key,
        isPatient: isPatient,
        doctorUid: doctorUid,
        isOpenCloseFeature: isOpenCloseFeature,
      );

      return Right(result);
    } catch (e) {
      debugPrint("❌ Repository Error (Delete): $e");
      return Left(AppError(e.toString()));
    }
  }
}