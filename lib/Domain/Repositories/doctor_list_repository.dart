// 📄 doctor_list_repository.dart

import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class DoctorListRepository {
  /// 🔍 Fetch doctor list
  Future<Either<AppError, List<DoctorListModel>>> getDoctorListDomain(
      Map<String, dynamic> query,
      );

  /// 📌 Fetch single doctor
  Future<Either<AppError, DoctorListModel>> getDoctorDomain(
      String id,
      );

  /// ➕ Add new doctor
  Future<Either<AppError, SuccessModel>> addDoctorDomain(
      DoctorListModel doctor,
      );

  /// 🔄 Update doctor
  Future<Either<AppError, SuccessModel>> updateDoctorDomain(
      String id,
      DoctorListModel doctor,
      );

  /// 🗑 Delete doctor
  Future<Either<AppError, SuccessModel>> deleteDoctorDomain(
      String id,
      );
}