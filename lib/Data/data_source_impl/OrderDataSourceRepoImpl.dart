import 'package:diwanclinic/Data/data_source/order_data_source.dart';
import '../../index/index_main.dart';

class OrderDataSourceRepoImpl extends OrderDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  OrderDataSourceRepoImpl(this._clientSourceRepo);

  // ─────────────────────────────────────────────
  // 📥 Get Orders (Online Only)
  // ─────────────────────────────────────────────
  @override
  Future<List<OrderModel?>> getOrders(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) async {
    try {
      // 🔹 Fetch all orders directly from Firebase (no cache)
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.orders}.json",
        params: data,
      );

      List<OrderModel?> orderList = handleResponse<OrderModel>(
        response,
            (json) => OrderModel.fromJson(json),
      );

      return orderList;
    } catch (e) {
      print("❌ Error while fetching online orders: $e");
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // ➕ Add New Order (Online Only)
  // ─────────────────────────────────────────────
  @override
  Future<SuccessModel> addOrder(Map<String, dynamic> data, String key) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.orders}/$key.json",
        params: data,
      );

      print("✅ Order added successfully to Firebase: $key");
      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ Error adding order online: $e");
      return SuccessModel(message: "فشل إضافة الطلب أونلاين");
    }
  }

  // ─────────────────────────────────────────────
  // 🔁 Update Existing Order (Online Only)
  // ─────────────────────────────────────────────
  @override
  Future<SuccessModel> updateOrder(Map<String, dynamic> data, String key) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.orders}/$key.json",
        params: data,
      );

      print("✅ Order updated successfully on Firebase: $key");
      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ Error updating order online: $e");
      return SuccessModel(message: "فشل تحديث الطلب أونلاين");
    }
  }

  // ─────────────────────────────────────────────
  // 🗑️ Delete Order (Online Only)
  // ─────────────────────────────────────────────
  @override
  Future<SuccessModel> deleteOrder(Map<String, dynamic> data, String key) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.DELETE,
        "/${ApiConstatns.orders}/$key.json",
        params: data,
      );

      print("🗑️ Order deleted successfully from Firebase: $key");
      return SuccessModel.fromJson(response ?? {"message": "تم الحذف بنجاح"});
    } catch (e) {
      print("❌ Error deleting order online: $e");
      return SuccessModel(message: "فشل حذف الطلب أونلاين");
    }
  }
}
