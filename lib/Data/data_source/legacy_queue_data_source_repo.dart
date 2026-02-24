import '../../index/index_main.dart';

abstract class LegacyQueueDataSourceRepo {

  Future<List<LegacyQueueModel?>> getLegacyQueueByDate(
      String date,
      Map<String, dynamic> data, {
        bool isPatient = false,
        String? doctorUid,
      });

  Future<List<LegacyQueueModel?>> getOpenCloseDaysByDate(
      String date,
      Map<String, dynamic> data, {
        bool isPatient = false,
        String? doctorUid,
      });

  Future<SuccessModel> addLegacyQueue(
      String date,
      String key,
      Map<String, dynamic> data, {
        bool isPatient = false,
        String? doctorUid,
      });

  Future<SuccessModel> updateLegacyQueue(
      String date,
      String key,
      Map<String, dynamic> data, {
        bool isPatient = false,
        String? doctorUid,
      });

  Future<SuccessModel> deleteLegacyQueue(
      String date,
      String key, {
        bool isPatient = false,
        String? doctorUid,
        bool isOpenCloseFeature = false,
      });
}