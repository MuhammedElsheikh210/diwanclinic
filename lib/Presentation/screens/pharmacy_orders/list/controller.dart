import 'package:intl/intl.dart';

import '../../../../index/index_main.dart';

class PharmacyOrdersListViewModel extends GetxController {
  final OrderService _service = OrderService();

  RxList<OrderModel> orders = <OrderModel>[].obs;

  bool showDailyReport = false;
  bool isRefreshing = false; // 👈 NEW

  DateTime selectedDate = DateTime.now();

  String get formattedDate => DateFormat('dd / MM / yyyy').format(selectedDate);

  @override
  void onInit() {
    fetchOrders();
    super.onInit();
  }

  void onDateChanged(DateTime date) {
    selectedDate = date;
    fetchOrders();
    update();
  }

  // ------------------------------------------------------------------
  // 🔄 PULL TO REFRESH
  // ------------------------------------------------------------------
  Future<void> refreshAll() async {
    isRefreshing = true;
    update();

    await fetchOrders();

    isRefreshing = false;
    update();
  }

  int _startOfDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.millisecondsSinceEpoch;
  }

  int _endOfDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    return d.millisecondsSinceEpoch;
  }

  Future<void> fetchOrders() async {
    final start = _startOfDay(selectedDate);
    final end = _endOfDay(selectedDate);

    await _service.getOrdersData(
      data: {},
      filrebaseFilter: FirebaseFilter(
        orderBy: "created_at",
        startAt: start,
        endAt: end,
      ),
      isFiltered: true,
      voidCallBack: (list) {
        final fetched = list.whereType<OrderModel>().toList();

        fetched.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));

        orders.value = fetched;
        update();
      },
    );
  }

  Future<void> updateOrderStatus({
    required OrderModel order,
    required String newStatus,
     String? reason,
  }) async {
    await OrderStatusService.updateOrderStatus(
      order: order,
      newStatus: newStatus,
      onSave: (updatedOrder) async {
        await _service.updateOrderData(
          order: updatedOrder,
          reason: reason,
          voidCallBack: (_) async {
            await fetchOrders();
          },
        );
        update();
      },
    );
  }
}
