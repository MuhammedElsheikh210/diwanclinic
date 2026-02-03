
import '../../index/index_main.dart';

abstract class DoctorSuggestionDataSourceRepo {
  /// 🔹 Get all doctor suggestions
  Future<List<DoctorSuggestionModel?>> getDoctorSuggestions(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );

  /// 🔹 Add new doctor suggestion
  Future<SuccessModel> addDoctorSuggestion(
    Map<String, dynamic> data,
    String key,
  );

  /// 🔹 Delete a doctor suggestion
  Future<SuccessModel> deleteDoctorSuggestion(
    Map<String, dynamic> data,
    String key,
  );

  /// 🔹 Update a doctor suggestion
  Future<SuccessModel> updateDoctorSuggestion(
    Map<String, dynamic> data,
    String key,
  );
}
