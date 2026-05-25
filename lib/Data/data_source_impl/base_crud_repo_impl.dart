import 'package:diwanclinic/Data/data_source/base_crud_repo.dart';

import '../../index/index_main.dart';

class BaseCrudRepoImpl<T> extends BaseCrudRepo<T> {
  final ClientSourceRepo client;

  final String baseUrl;

  /// model parser
  final T Function(Map<String, dynamic>) fromJson;

  BaseCrudRepoImpl({
    required this.client,
    required this.baseUrl,
    required this.fromJson,
  });

  /// =========================
  /// GET ALL
  /// =========================
  @override
  Future<List<T?>> getAll(Map<String, dynamic> data) async {
    try {
      final response = await client.request(
        HttpMethod.GET,
        "${ApiConstatns.Base_Url}/$baseUrl.json",
        params: data,
      );

      return handleResponse<T>(response, fromJson);
    } catch (e) {
      return [];
    }
  }

  /// =========================
  /// ADD
  /// =========================
  @override
  Future<SuccessModel> add(Map<String, dynamic> data, String id) async {
    try {
      final response = await client.request(
        HttpMethod.PATCH,
        "/$baseUrl/$id.json",
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      return SuccessModel(message: "Add Failed");
    }
  }

  /// =========================
  /// DELETE
  /// =========================
  @override
  Future<SuccessModel> delete(Map<String, dynamic> data, String id) async {
    try {
      final response = await client.request(
        HttpMethod.DELETE,
        "/$baseUrl/$id.json",
        params: data,
      );

      return response == null
          ? SuccessModel(message: "تمت العملية بنجاح")
          : SuccessModel.fromJson(response);
    } catch (e) {
      return SuccessModel(message: "Delete Failed");
    }
  }

  /// =========================
  /// UPDATE
  /// =========================
  @override
  Future<SuccessModel> update(Map<String, dynamic> data, String id) async {
    try {
      final response = await client.request(
        HttpMethod.PATCH,
        "/$baseUrl/$id.json",
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      return SuccessModel(message: "Update Failed");
    }
  }
}
