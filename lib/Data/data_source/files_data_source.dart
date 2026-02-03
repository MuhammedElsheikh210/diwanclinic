
import '../../index/index_main.dart';

abstract class FilesDataSourceRepo {
  Future<List<FilesModel?>> getFiles(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  Future<SuccessModel> addFile(Map<String, dynamic> data, String key);

  Future<SuccessModel> deleteFile(Map<String, dynamic> data, String key);

  Future<SuccessModel> updateFile(Map<String, dynamic> data, String key);
}
