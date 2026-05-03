import '../../../../index/index_main.dart';

class OrdersListViewModel extends GetxController {
  // ============================================================
  // 🧠 DATA
  // ============================================================

  RxList<OrderModel> orders = <OrderModel>[].obs;

  bool isLoading = false;

  // ============================================================
  // 📊 FILTERS
  // ============================================================

  List<OrderModel> get activeOrders {
    return orders
        .where((o) => o.status != "delivered" && o.status != "cancelled")
        .toList();
  }

  List<OrderModel> get finishedOrders {
    return orders
        .where((o) => o.status == "delivered" || o.status == "cancelled")
        .toList();
  }

  // ============================================================
  // 🚀 INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();
  }

  // ============================================================
  // 🔁 UPSERT (🔥 أهم فانكشن)
  // ============================================================

  void upsertOrder(OrderModel model) {
    final index = orders.indexWhere((e) => e.key == model.key);

    if (index != -1) {
      orders[index] = model;
    } else {
      orders.insert(0, model);
    }

    orders.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    orders.refresh();
  }

  // ============================================================
  // 🔄 REMOVE
  // ============================================================

  void removeOrder(String key) {
    orders.removeWhere((e) => e.key == key);
    orders.refresh();
  }

  // ============================================================
  // 🔄 UPDATE STATUS
  // ============================================================

  Future<void> updateOrderStatus({
    required OrderModel order,
    required String newStatus,
  }) async {
    final updatedOrder = order.copyWith(status: newStatus);

    final result = await Get.find<PatientOrderService>().useCase.updateOrder(
      updatedOrder,
    );

    result.fold((error) {}, (_) {});
  }

  // ============================================================
  // 🔄 REFRESH
  // ============================================================

  Future<void> refreshAll() async {
    orders.clear();
    orders.refresh();
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  @override
  void onClose() {
    super.onClose();
  }
}
