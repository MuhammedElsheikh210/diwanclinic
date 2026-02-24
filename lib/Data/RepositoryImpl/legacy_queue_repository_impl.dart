import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class LegacyQueueRepositoryImpl extends LegacyQueueRepository {
  final LegacyQueueDataSourceRepo _dataSource;

  LegacyQueueRepositoryImpl(this._dataSource);

  // ------------------------------------------------------------
  // 🧾 Legacy Queue (الكشوفات الورقية)
  // ------------------------------------------------------------
  @override
  Future<Either<AppError, List<LegacyQueueModel?>>>
  getLegacyQueueByDateDomain(
      String date,
      Map<String, dynamic> params, {
        bool isPatient = false,
        String? doctorUid,
      }) async {
    try {
      final result = await _dataSource.getLegacyQueueByDate(
        date,
        params,
        isPatient: isPatient,
        doctorUid: doctorUid,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addLegacyQueueDomain(
      String date,
      String key,
      Map<String, dynamic> data, {
        bool isPatient = false,
        String? doctorUid,
        String? shiftKey,
      }) async {
    try {
      final result = await _dataSource.addLegacyQueue(
        date,
        key,
        data,
        isPatient: isPatient,
        doctorUid: doctorUid,
        shiftKey: shiftKey, // ✅ جديد
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateLegacyQueueDomain(
      String date,
      String key,
      Map<String, dynamic> data, {
        bool isPatient = false,
        String? doctorUid,
        String? shiftKey,
      }) async {
    try {
      final result = await _dataSource.updateLegacyQueue(
        date,
        key,
        data,
        isPatient: isPatient,
        doctorUid: doctorUid,
        shiftKey: shiftKey, // ✅ جديد
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteLegacyQueueDomain(
      String date,
      String key, {
        bool isPatient = false,
        String? doctorUid,
        bool isOpenCloseFeature = false,
        String? shiftKey,
      }) async {
    try {
      final result = await _dataSource.deleteLegacyQueue(
        date,
        key,
        isPatient: isPatient,
        doctorUid: doctorUid,
        isOpenCloseFeature: isOpenCloseFeature,
        shiftKey: shiftKey, // ✅ جديد
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ------------------------------------------------------------
  // 🔒 Open / Close Days (فتح / غلق الحجوزات) - WITH SHIFT
  // ------------------------------------------------------------
  @override
  Future<Either<AppError, List<LegacyQueueModel?>>>
  getOpenCloseDaysByDateDomain(
      String date, {
        required String shiftKey, // ✅ مهم
        bool isPatient = false,
        String? doctorUid,
      }) async {
    try {
      final result = await _dataSource.getOpenCloseDaysByDate(
        date,
        shiftKey: shiftKey, // ✅ مهم جدًا
        isPatient: isPatient,
        doctorUid: doctorUid,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}