import '../../index/index_main.dart';

abstract class OrderDataSourceRepo {

  // ============================================================
  // 🔥 REALTIME CONTROL
  // ============================================================

  Future<void> startListening();

  Future<void> stopListening();

  // ============================================================
  // 🔥 REALTIME STREAMS
  // ============================================================

  Stream<OrderModel> get onAdded;

  Stream<OrderModel> get onChanged;

  Stream<String> get onRemoved;

  // ============================================================
  // 🌐 FETCH
  // ============================================================

  Future<List<OrderModel?>> getOrders(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  /// 🔥 NEW
  Future<List<OrderModel>> fetchAllOrders();

  // ============================================================
  // CRUD
  // ============================================================

  Future<SuccessModel> addOrder(
      Map<String, dynamic> data,
      String key,
      );

  Future<SuccessModel> updateOrder(
      Map<String, dynamic> data,
      String key,
      );

  Future<SuccessModel> deleteOrder(
      Map<String, dynamic> data,
      String key,
      );
}