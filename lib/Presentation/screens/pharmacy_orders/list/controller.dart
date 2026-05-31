import 'package:intl/intl.dart';

import '../../../../index/index_main.dart';

class PharmacyOrdersListViewModel extends GetxController {
  final OrderService _service = OrderService();

  RxList<OrderModel> orders = <OrderModel>[].obs;

  bool showDailyReport = false;

  bool isRefreshing = false;

  DateTime selectedDate = DateTime.now();

  String get formattedDate => DateFormat('dd / MM / yyyy').format(selectedDate);

  // ============================================================
  // 🚀 INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    _initRealtime();
  }

  // ============================================================
  // 🔥 REALTIME INIT
  // ============================================================

  Future<void> _initRealtime() async {
    // ============================================================
    // 🌐 FIRST FETCH
    // ============================================================

    await fetchOrders();

    // ============================================================
    // 🎧 START LISTENING
    // ============================================================

    await _service.startListening();

    // ============================================================
    // 🟢 ADDED
    // ============================================================

    _service.onOrderAdded = (order) {
      onRealtimeAdd(order);
    };

    // ============================================================
    // 🔄 UPDATED
    // ============================================================

    _service.onOrderUpdated = (order) {
      onRealtimeUpdate(order);
    };

    // ============================================================
    // ❌ REMOVED
    // ============================================================

    _service.onOrderRemoved = (key) {
      onRealtimeDelete(key);
    };
  }

  // ============================================================
  // 📅 DATE CHANGE
  // ============================================================

  void onDateChanged(DateTime date) {
    selectedDate = date;

    fetchOrders();

    update();
  }

  // ============================================================
  // 🔄 REFRESH
  // ============================================================

  Future<void> refreshAll() async {
    // isRefreshing = true;
    //
    // update();
    //
    // await fetchOrders();
    //
    // isRefreshing = false;
    //
    // update();
  }

  // ============================================================
  // ⏰ DAY HELPERS
  // ============================================================

  int _startOfDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);

    return d.millisecondsSinceEpoch;
  }

  int _endOfDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    return d.millisecondsSinceEpoch;
  }

  bool _isInsideSelectedDay(OrderModel order) {
    final createdAt = order.createdAt ?? 0;

    final start = _startOfDay(selectedDate);

    final end = _endOfDay(selectedDate);

    return createdAt >= start && createdAt <= end;
  }

  // ============================================================
  // 🌐 FETCH
  // ============================================================

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

  // ============================================================
  // 🟢 REALTIME ADD
  // ============================================================

  void onRealtimeAdd(OrderModel order) {
    /// ✅ day filter
    if (!_isInsideSelectedDay(order)) {
      return;
    }

    /// ✅ duplicate protection
    final exists = orders.any((o) => o.key == order.key);

    if (exists) return;

    orders.insert(0, order);

    _sort();

    orders.refresh();

    update();
  }

  // ============================================================
  // 🔄 REALTIME UPDATE
  // ============================================================

  void onRealtimeUpdate(OrderModel order) {
    /// ❌ لو مبقاش في نفس اليوم بعد التعديل
    if (!_isInsideSelectedDay(order)) {
      orders.removeWhere((o) => o.key == order.key);

      orders.refresh();

      update();

      return;
    }

    orders.value =
        orders.map((o) {
          if (o.key == order.key) {
            return order;
          }

          return o;
        }).toList();

    _sort();

    orders.refresh();

    update();
  }

  // ============================================================
  // ❌ REALTIME DELETE
  // ============================================================

  void onRealtimeDelete(String key) {
    orders.removeWhere((o) => o.key == key);

    orders.refresh();

    update();
  }

  // ============================================================
  // 🔀 SORT
  // ============================================================

  void _sort() {
    orders.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
  }

  // ============================================================
  // 🔄 UPDATE STATUS
  // ============================================================

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
          voidCallBack: (_) {},
        );
      },
    );
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  @override
  void onClose() {
    _service.dispose();

    super.onClose();
  }
}
