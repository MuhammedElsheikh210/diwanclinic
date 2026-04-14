import 'package:diwanclinic/Data/data_source/files_data_source.dart';

import '../../index/index_main.dart';

class FilesDataSourceRepoImpl extends FilesDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;
  final BaseSQLiteDataSourceRepo<FilesModel> _sqliteRepo;

  FilesDataSourceRepoImpl(this._clientSourceRepo)
    : _sqliteRepo = BaseSQLiteDataSourceRepo<FilesModel>(
        tableName: "files",
        fromJson: (json) => FilesModel.fromJson(json),
        toJson: (model) => model.toJson(),
        idColumn: "key",
        getId: (model) => model.key,
      );

  @override
  Future<List<FilesModel?>> getFiles(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      final sqliteData = await _sqliteRepo.getAll(query: query);
      if (sqliteData.isNotEmpty || (sqliteData.isEmpty && isFiltered == true)) {
        return sqliteData;
      }
    } catch (_) {}

    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.files}.json",
        params: data,
      );

      List<FilesModel?> fileList = handleResponse<FilesModel>(
        response,
        (json) => FilesModel.fromJson(json),
      );

      for (final file in fileList) {
        if (file?.key?.isNotEmpty == true) {
          await _sqliteRepo.addItem(file!);
        }
      }

      return fileList;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<SuccessModel> addFile(Map<String, dynamic> data, String key) async {
    final file = FilesModel.fromJson(data);
    await _sqliteRepo.addItem(file);

    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.files}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }

  @override
  Future<SuccessModel> deleteFile(Map<String, dynamic> data, String key) async {
    await _sqliteRepo.deleteItem(key);

    final response = await _clientSourceRepo.request(
      HttpMethod.DELETE,
      "/${ApiConstatns.files}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response ?? {"message": "تمت العملية بنجاح"});
  }

  @override
  Future<SuccessModel> updateFile(Map<String, dynamic> data, String key) async {
    final file = FilesModel.fromJson(data);
    await _sqliteRepo.updateItem(file);

    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.files}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }
}
