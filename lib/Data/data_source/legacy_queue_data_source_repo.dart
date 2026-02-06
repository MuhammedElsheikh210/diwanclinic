import '../../index/index_main.dart';

abstract class LegacyQueueDataSourceRepo {
  /// 🧾 Legacy Queue (الكشوفات الورقية)
  Future<List<LegacyQueueModel?>> getLegacyQueueByDate(
      String date,
      Map<String, dynamic> params, {
        bool isPatient = false,
        String? doctorUid,
      });

  /// 🔒 Open / Close Days (فتح / غلق الحجوزات)
  Future<List<LegacyQueueModel?>> getOpenCloseDaysByDate(
      String date, {
        bool isPatient = false,
        String? doctorUid,
      });

  /// ➕ ADD (Legacy أو Open/Close حسب data)
  Future<SuccessModel> addLegacyQueue(
      String date,
      String key,
      Map<String, dynamic> data, {
        bool isPatient = false,
        String? doctorUid,
      });

  /// ✏️ UPDATE (Legacy أو Open/Close حسب data)
  Future<SuccessModel> updateLegacyQueue(
      String date,
      String key,
      Map<String, dynamic> data, {
        bool isPatient = false,
        String? doctorUid,
      });

  /// 🗑 DELETE
  Future<SuccessModel> deleteLegacyQueue(
      String date,
      String key, {
        bool isPatient = false,
        String? doctorUid,
        bool isOpenCloseFeature = false, // 👈 مهم
      });
}
