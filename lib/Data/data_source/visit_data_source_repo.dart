import '../../index/index_main.dart';

abstract class VisitDataSourceRepo {
  /// 🔹 Get a list of visits with optional filtering
  Future<List<VisitModel?>> getVisits(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );

  /// 🔹 Get a single visit by query or ID
  Future<VisitModel> getVisit(Map<String, dynamic> data);

  /// 🔹 Add a new visit
  Future<SuccessModel> addVisit(Map<String, dynamic> data, String id);

  /// 🔹 Delete a visit
  Future<SuccessModel> deleteVisit(Map<String, dynamic> data, String id);

  /// 🔹 Update an existing visit
  Future<SuccessModel> updateVisit(Map<String, dynamic> data, String id);
}
