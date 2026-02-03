import '../../index/index_main.dart';

abstract class AssistantDataSourceRepo {
  Future<List<AssistantModel?>> getAssistants(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );

  Future<SuccessModel> addAssistant(Map<String, dynamic> data, String key);

  Future<SuccessModel> deleteAssistant(Map<String, dynamic> data, String key);

  Future<SuccessModel> updateAssistant(Map<String, dynamic> data, String key);
}
