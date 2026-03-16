import 'package:dartz/dartz.dart';

import '../../index/index_main.dart';

abstract class LegacyQueueRepository {
  Future<Either<AppError, List<LegacyQueueModel?>>> getLegacyQueueByDateDomain(
    Map<String, dynamic> params, {
    bool isPatient = false,
    String? doctorUid,
  });

  Future<Either<AppError, SuccessModel>> addLegacyQueueDomain(
    String date,
    String key,
    Map<String, dynamic> data, {
    bool isPatient = false,
    String? doctorUid,
  });

  Future<Either<AppError, SuccessModel>> updateLegacyQueueDomain(
    String date,
    String key,
    Map<String, dynamic> data, {
    bool isPatient = false,
    String? doctorUid,
  });

  Future<Either<AppError, SuccessModel>> deleteLegacyQueueDomain(
    String date,
    String key, {
    bool isPatient = false,
    String? doctorUid,
    bool isOpenCloseFeature = false,
  });

  // 🔥 FIXED HERE
  Future<Either<AppError, List<LegacyQueueModel?>>>
  getOpenCloseDaysByDateDomain(
    String date,
    Map<String, dynamic> params, { // ← أضف ده
    bool isPatient = false,
    String? doctorUid,
  });
}
