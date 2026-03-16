import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class MedicalCenterRepository {

  /// 🔍 Fetch all medical centers
  Future<Either<AppError, List<MedicalCenterModel?>>> getMedicalCentersDomain(
      Map<String, dynamic> data,
      );

  /// 📌 Fetch a single medical center
  Future<Either<AppError, MedicalCenterModel>> getMedicalCenterDomain(
      Map<String, dynamic> data,
      );

  /// ➕ Add a new medical center
  Future<Either<AppError, SuccessModel>> addMedicalCenterDomain(
      Map<String, dynamic> data,
      String id,
      );

  /// 🗑 Delete a medical center
  Future<Either<AppError, SuccessModel>> deleteMedicalCenterDomain(
      Map<String, dynamic> data,
      String id,
      );

  /// 🔄 Update a medical center
  Future<Either<AppError, SuccessModel>> updateMedicalCenterDomain(
      Map<String, dynamic> data,
      String id,
      );
}