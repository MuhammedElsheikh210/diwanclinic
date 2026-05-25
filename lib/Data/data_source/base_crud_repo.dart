import '../../index/index_main.dart';

abstract class BaseCrudRepo<T> {
  /// 🔹 Get all items
  Future<List<T?>> getAll(
      Map<String, dynamic> data,
      );

  /// 🔹 Add item
  Future<SuccessModel> add(
      Map<String, dynamic> data,
      String id,
      );

  /// 🔹 Delete item
  Future<SuccessModel> delete(
      Map<String, dynamic> data,
      String id,
      );

  /// 🔹 Update item
  Future<SuccessModel> update(
      Map<String, dynamic> data,
      String id,
      );
}