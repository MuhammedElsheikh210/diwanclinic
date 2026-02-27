import '../../index/index_main.dart';

abstract class DoctorListRemoteDataSource {
  Future<List<DoctorListModel>> getDoctorList(Map<String, dynamic> query);

  Future<DoctorListModel> getDoctor(String id);

  Future<SuccessModel> addDoctor(DoctorListModel doctor);

  Future<SuccessModel> updateDoctor(String id, DoctorListModel doctor);

  Future<SuccessModel> deleteDoctor(String id);
}
