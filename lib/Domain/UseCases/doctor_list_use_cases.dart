// 📄 doctor_list_use_cases.dart

import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class DoctorListUseCases {
  final DoctorListRepository _repository;

  DoctorListUseCases(this._repository);

  /// ➕ Add a new doctor
  Future<Either<AppError, SuccessModel>> addDoctor(
      DoctorListModel doctor) {
    return _repository.addDoctorDomain(doctor);
  }

  /// 🔄 Update doctor
  Future<Either<AppError, SuccessModel>> updateDoctor(
      DoctorListModel doctor) {
    return _repository.updateDoctorDomain(
        doctor.key ?? "", doctor);
  }

  /// 🗑 Delete doctor
  Future<Either<AppError, SuccessModel>> deleteDoctor(
      String key) {
    return _repository.deleteDoctorDomain(key);
  }

  /// 🔍 Get doctor list
  Future<Either<AppError, List<DoctorListModel>>> getDoctorList(
      Map<String, dynamic> query) {
    return _repository.getDoctorListDomain(query);
  }

  /// 📌 Get single doctor
  Future<Either<AppError, DoctorListModel>> getDoctor(
      String id) {
    return _repository.getDoctorDomain(id);
  }
}