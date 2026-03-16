
import '../../index/index_main.dart';

abstract class MedicalCenterDataSourceRepo {
  Future<List<MedicalCenterModel?>> getMedicalCenters(
    Map<String, dynamic> data,
  );

  Future<MedicalCenterModel> getMedicalCenter(Map<String, dynamic> data);

  Future<SuccessModel> addMedicalCenter(Map<String, dynamic> data, String id);

  Future<SuccessModel> deleteMedicalCenter(
    Map<String, dynamic> data,
    String id,
  );

  Future<SuccessModel> updateMedicalCenter(
    Map<String, dynamic> data,
    String id,
  );

}
