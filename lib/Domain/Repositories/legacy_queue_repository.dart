import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class LegacyQueueRepository {
  // ------------------------------------------------------------
  // 🧾 Legacy Queue (الكشوفات الورقية)
  // ------------------------------------------------------------
  Future<Either<AppError, List<LegacyQueueModel?>>>
  getLegacyQueueByDateDomain(
      String date,
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
        String? shiftKey, // ✅ جديد (لو Open/Close)
      });

  Future<Either<AppError, SuccessModel>> updateLegacyQueueDomain(
      String date,
      String key,
      Map<String, dynamic> data, {
        bool isPatient = false,
        String? doctorUid,
        String? shiftKey, // ✅ جديد
      });

  Future<Either<AppError, SuccessModel>> deleteLegacyQueueDomain(
      String date,
      String key, {
        bool isPatient = false,
        String? doctorUid,
        bool isOpenCloseFeature = false,
        String? shiftKey, // ✅ جديد
      });

  // ------------------------------------------------------------
  // 🔒 Open / Close Days (فتح / غلق الحجوزات) - WITH SHIFT
  // ------------------------------------------------------------
  Future<Either<AppError, List<LegacyQueueModel?>>>
  getOpenCloseDaysByDateDomain(
      String date, {
        required String shiftKey, // ✅ مهم جدًا
        bool isPatient = false,
        String? doctorUid,
      });
}