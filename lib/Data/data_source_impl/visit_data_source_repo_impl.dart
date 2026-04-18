import 'package:diwanclinic/Data/data_source/visit_data_source_repo.dart';
import '../../index/index_main.dart';

class VisitDataSourceRepoImpl extends VisitDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;
  // final BaseSQLiteDataSourceRepo<VisitModel> _sqliteRepo;

  VisitDataSourceRepoImpl(this._clientSourceRepo)
  /* : _sqliteRepo = BaseSQLiteDataSourceRepo<VisitModel>(
          tableName: "visits",
          fromJson: (json) => VisitModel.fromJson(json),
          toJson: (model) => model.toJson(),
          getId: (model) => model.name,
        ); */;

  @override
  Future<List<VisitModel?>> getVisits(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) async {
    try {
      // final sqliteData = await _sqliteRepo.getAll(query: query);
      // if (sqliteData.isNotEmpty || (sqliteData.isEmpty && isFiltered == true)) {
      //   return sqliteData;
      // }

      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.visits}.json",
        params: data,
      );

      List<VisitModel?> visitList = handleResponse<VisitModel>(
        response,
            (json) => VisitModel.fromJson(json),
      );

      // for (final visit in visitList) {
      //   if (visit?.name.isNotEmpty == true) {
      //     await _sqliteRepo.addItem(visit!);
      //   }
      // }

      return visitList;
    } catch (e) {
      
      return [];
    }
  }

  @override
  Future<VisitModel> getVisit(Map<String, dynamic> data) async {
    try {
      // final key = data['name'] as String;
      // final localVisit = await _sqliteRepo.getItem(key);
      // if (localVisit != null) return localVisit;

      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.visits}.json",
        params: data,
      );

      final visitJson = response.values.first as Map<String, dynamic>;
      final visit = VisitModel.fromJson(visitJson);

      // await _sqliteRepo.addItem(visit);
      return visit;
    } catch (e) {
      
      rethrow;
    }
  }

  @override
  Future<SuccessModel> addVisit(Map<String, dynamic> data, String id) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.visits}/$id.json",
        params: data,
      );
      // final model = VisitModel.fromJson(data);
      // await _sqliteRepo.addItem(model);
      return SuccessModel.fromJson(response);
    } catch (e) {
      
      return SuccessModel(message: "Add Visit failed");
    }
  }

  @override
  Future<SuccessModel> deleteVisit(
      Map<String, dynamic> data,
      String id,
      ) async {
    try {
      // await _sqliteRepo.deleteItem(id);

      final response = await _clientSourceRepo.request(
        HttpMethod.DELETE,
        "/${ApiConstatns.visits}/$id.json",
        params: data,
      );

      return response == null
          ? SuccessModel(message: "تمت العملية بنجاح")
          : SuccessModel.fromJson(response);
    } catch (e) {
      
      return SuccessModel(message: "Delete Visit failed");
    }
  }

  @override
  Future<SuccessModel> updateVisit(
      Map<String, dynamic> data,
      String id,
      ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.visits}/$id.json",
        params: data,
      );

      // final model = VisitModel.fromJson(data);
      // await _sqliteRepo.updateItem(model);

      return SuccessModel.fromJson(response);
    } catch (e) {
      
      return SuccessModel(message: "Update Visit failed");
    }
  }
}
