import '../../index/index_main.dart';

class DoctorSuggestionDataSourceRepoImpl
    extends DoctorSuggestionDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  DoctorSuggestionDataSourceRepoImpl(this._clientSourceRepo);

  @override
  Future<List<DoctorSuggestionModel?>> getDoctorSuggestions(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      print(
        "🌐 [DoctorSuggestionDataSource] Fetching doctor suggestions online...",
      );

      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.doctorSuggestions}.json",
        params: data,
      );

      List<DoctorSuggestionModel?> suggestions =
          handleResponse<DoctorSuggestionModel>(
            response,
            (json) => DoctorSuggestionModel.fromJson(json),
          );

      print(
        "✅ [DoctorSuggestionDataSource] Total suggestions fetched: ${suggestions.length}",
      );
      return suggestions;
    } catch (e) {
      print(
        "❌ [DoctorSuggestionDataSource] Failed to fetch doctor suggestions: $e",
      );
      return [];
    }
  }

  @override
  Future<SuccessModel> addDoctorSuggestion(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final suggestion = DoctorSuggestionModel.fromJson(data);

      print(
        "🌐 [DoctorSuggestionDataSource] Adding doctor suggestion for ${suggestion.doctorName}",
      );

      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.doctorSuggestions}/$key.json",
        params: data,
      );

      print(
        "✅ [DoctorSuggestionDataSource] Suggestion added successfully online",
      );
      return SuccessModel.fromJson(response);
    } catch (e) {
      print(
        "❌ [DoctorSuggestionDataSource] Error adding doctor suggestion: $e",
      );
      return SuccessModel(message: "حدث خطأ أثناء إضافة اقتراح الطبيب");
    }
  }

  @override
  Future<SuccessModel> deleteDoctorSuggestion(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      print(
        "🌐 [DoctorSuggestionDataSource] Deleting doctor suggestion $key online",
      );

      final response = await _clientSourceRepo.request(
        HttpMethod.DELETE,
        "/${ApiConstatns.doctorSuggestions}/$key.json",
        params: data,
      );

      print(
        "✅ [DoctorSuggestionDataSource] Doctor suggestion deleted successfully online",
      );
      return SuccessModel.fromJson(response ?? {"message": "تم الحذف بنجاح"});
    } catch (e) {
      print(
        "❌ [DoctorSuggestionDataSource] Error deleting doctor suggestion: $e",
      );
      return SuccessModel(message: "فشل حذف اقتراح الطبيب");
    }
  }

  @override
  Future<SuccessModel> updateDoctorSuggestion(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final suggestion = DoctorSuggestionModel.fromJson(data);

      print(
        "🌐 [DoctorSuggestionDataSource] Updating suggestion ${suggestion.key} online",
      );

      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.doctorSuggestions}/$key.json",
        params: data,
      );

      print(
        "✅ [DoctorSuggestionDataSource] Suggestion updated successfully online",
      );
      return SuccessModel.fromJson(response);
    } catch (e) {
      print(
        "❌ [DoctorSuggestionDataSource] Error updating doctor suggestion: $e",
      );
      return SuccessModel(message: "فشل تحديث اقتراح الطبيب");
    }
  }
}
