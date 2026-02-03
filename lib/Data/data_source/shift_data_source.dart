import '../../index/index_main.dart';

abstract class ShiftDataSourceRepo {
  Future<List<ShiftModel?>> getShifts(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );

  Future<List<ShiftModel?>> getShiftssFromPatient(
      Map<String, dynamic> data,
      String? doctorKey,
      );

  Future<SuccessModel> addShift(Map<String, dynamic> data, String key);

  Future<SuccessModel> deleteShift(Map<String, dynamic> data, String key);

  Future<SuccessModel> updateShift(Map<String, dynamic> data, String key);
}
