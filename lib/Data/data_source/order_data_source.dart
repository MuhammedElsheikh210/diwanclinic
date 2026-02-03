
import '../../index/index_main.dart';

/// 🧾 Abstract Repository Contract for Order Data
/// Defines all CRUD operations for Firebase + SQLite layers
abstract class OrderDataSourceRepo {
  /// 🔹 Fetch list of orders (supports filtering via SQLiteQueryParams)
  Future<List<OrderModel?>> getOrders(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  /// 🔹 Add new order (to Firebase + local SQLite)
  Future<SuccessModel> addOrder(Map<String, dynamic> data, String key);

  /// 🔹 Update existing order (to Firebase + local SQLite)
  Future<SuccessModel> updateOrder(Map<String, dynamic> data, String key);

  /// 🔹 Delete order (by key)
  Future<SuccessModel> deleteOrder(Map<String, dynamic> data, String key);
}
