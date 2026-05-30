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

  static const _finishedStatuses = {"delivered", "completed", "cancelled"};

  List<OrderModel> get activeOrders =>
      orders.where((o) => !_finishedStatuses.contains(o.status)).toList();

  List<OrderModel> get finishedOrders =>
      orders.where((o) => _finishedStatuses.contains(o.status)).toList();

  // ============================================================
  // 🚀 INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    // sync من HomePatientController اللي بيستلم كل الـ realtime events دايمًا
    if (Get.isRegistered<HomePatientController>()) {
      final home = Get.find<HomePatientController>();
      if (home.orders.isNotEmpty) {
        orders.value = List.from(home.orders);
        orders.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
        orders.refresh();
      }
    }
  }

  // ============================================================
  // 🔁 UPSERT (🔥 أهم فانكشن)
  // ============================================================

  void upsertOrder(OrderModel model) {
    final index = orders.indexWhere((e) => e.key == model.key);
    debugPrint('[ORDER_SYNC] OrdersListVM.upsertOrder → key=${model.key} status=${model.status} index=$index totalOrders=${orders.length}');

    if (index != -1) {
      orders[index] = model;
    } else {
      orders.insert(0, model);
    }

    orders.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    orders.refresh();
    debugPrint('[ORDER_SYNC] after refresh → activeOrders=${activeOrders.length} finishedOrders=${finishedOrders.length}');
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
