import '../../index/index_main.dart';

class AssistantDataSourceRepoImpl extends AssistantDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;
  // final BaseSQLiteDataSourceRepo<AssistantModel> _sqliteRepo;

  AssistantDataSourceRepoImpl(this._clientSourceRepo)
  /*: _sqliteRepo = BaseSQLiteDataSourceRepo<AssistantModel>(
          tableName: "assistants",
          fromJson: (json) => AssistantModel.fromJson(json),
          toJson: (model) => model.toJson(),
          getId: (model) => model.key,
        )*/;

  @override
  Future<List<AssistantModel?>> getAssistants(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) async {
    try {
      // 🔸 Local fetch (disabled)
      // final sqliteData = await _sqliteRepo.getAll(query: query);
      // if (sqliteData.isNotEmpty || (sqliteData.isEmpty && isFiltered == true)) {
      //   return sqliteData;
      // }
    } catch (_) {}

    try {
      // 🔹 Online fetch
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.assistants}.json",
        params: data,
      );

      List<AssistantModel?> assistantList = handleResponse<AssistantModel>(
        response,
            (json) => AssistantModel.fromJson(json),
      );

      // 🔸 Save to local (disabled)
      // for (final assistant in assistantList) {
      //   if (assistant?.key?.isNotEmpty == true) {
      //     await _sqliteRepo.addItem(assistant!);
      //   }
      // }

      return assistantList;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<SuccessModel> addAssistant(Map<String, dynamic> data, String key) async {
    final assistant = AssistantModel.fromJson(data);

    // 🔸 Local add (disabled)
    // await _sqliteRepo.addItem(assistant);

    // 🔹 Online add
    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.assistants}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }

  @override
  Future<SuccessModel> deleteAssistant(Map<String, dynamic> data, String key) async {
    // 🔸 Local delete (disabled)
    // await _sqliteRepo.deleteItem(key);

    // 🔹 Online delete
    final response = await _clientSourceRepo.request(
      HttpMethod.DELETE,
      "/${ApiConstatns.assistants}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response ?? {"message": "تمت العملية بنجاح"});
  }

  @override
  Future<SuccessModel> updateAssistant(Map<String, dynamic> data, String key) async {
    final assistant = AssistantModel.fromJson(data);

    // 🔸 Local update (disabled)
    // await _sqliteRepo.updateItem(assistant);

    // 🔹 Online update
    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.assistants}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }
}
