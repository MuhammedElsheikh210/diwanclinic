import '../../index/index_main.dart';

abstract class ShiftDataSourceRepo {
  /// 🔹 Get Shifts (Local First / Force Online)
  Future<List<ShiftModel?>> getShifts(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered, {
    bool? fromOnline,
  });

  /// 🔹 Fetch shifts related to a doctor (patient side)
  Future<List<ShiftModel?>> getShiftssFromPatient(
    Map<String, dynamic> data,
    String? doctorKey,
  );

  /// 🔹 Add new shift
  Future<SuccessModel> addShift(Map<String, dynamic> data, String key);

  /// 🔹 Delete shift
  Future<SuccessModel> deleteShift(Map<String, dynamic> data, String key);

  /// 🔹 Update shift
  Future<SuccessModel> updateShift(Map<String, dynamic> data, String key);
}
