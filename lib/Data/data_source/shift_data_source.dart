import '../../index/index_main.dart';

abstract class ShiftDataSourceRepo {

  /// 🕒 Get shifts for doctor
  Future<List<ShiftModel?>> getShifts(
      Map<String, dynamic> data,
      String? doctorKey,
      );

  /// 👨‍⚕️ Get shifts for patient view
  Future<List<ShiftModel?>> getShiftsFromPatient(
      Map<String, dynamic> data,
      String? doctorKey,
      );

  /// ➕ Add shift
  Future<SuccessModel> addShift(
      Map<String, dynamic> data,
      String key,
      String? doctorKey,
      );

  /// ❌ Delete shift
  Future<SuccessModel> deleteShift(
      Map<String, dynamic> data,
      String key,
      String? doctorKey,
      );

  /// ✏️ Update shift
  Future<SuccessModel> updateShift(
      Map<String, dynamic> data,
      String key,
      String? doctorKey,
      );
}