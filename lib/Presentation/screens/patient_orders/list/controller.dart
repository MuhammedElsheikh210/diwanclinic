import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';

class OrdersListViewModel extends GetxController {
  // 🔥 Realtime data
  RxList<OrderModel> orders = <OrderModel>[].obs;

  // 🔄 Firebase listeners
  StreamSubscription<DatabaseEvent>? _addSub;
  StreamSubscription<DatabaseEvent>? _changeSub;
  StreamSubscription<DatabaseEvent>? _removeSub;

  bool isLoading = false;

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    fetchOrders(); // 👈 same name, but realtime
  }

  // ---------------------------------------------------------------------------
  // 📥 FETCH ORDERS (REALTIME LISTENER – Firebase only)
  // ---------------------------------------------------------------------------
  Future<void> fetchOrders() async {
    final patientKey = LocalUser().getUserData().key;

    if (patientKey == null || patientKey.isEmpty) {
      isLoading = false;
      update();
      return;
    }

    isLoading = true;
    update();

    final DatabaseReference ref = FirebaseDatabase.instance.ref("orders");

    // 🟢 ORDER ADDED
    _addSub = ref.onChildAdded.listen((event) {
      if (event.snapshot.value == null) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      if (data["patient_key"] != patientKey) return;

      final order = OrderModel.fromJson(data);
      _upsertOrder(order);

      isLoading = false;
      update();
    });

    // 🔄 ORDER UPDATED
    _changeSub = ref.onChildChanged.listen((event) {
      if (event.snapshot.value == null) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      if (data["patient_key"] != patientKey) return;

      final order = OrderModel.fromJson(data);
      _upsertOrder(order);
      update();
    });

    // ❌ ORDER REMOVED
    _removeSub = ref.onChildRemoved.listen((event) {
      if (event.snapshot.value == null) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      final removedKey = data["key"];
      orders.removeWhere((o) => o.key == removedKey);
      update();
    });
  }

  // ---------------------------------------------------------------------------
  // 🔁 ADD OR UPDATE ORDER IN MEMORY
  // ---------------------------------------------------------------------------
  void _upsertOrder(OrderModel order) {
    final index = orders.indexWhere((o) => o.key == order.key);

    if (index == -1) {
      orders.insert(0, order); // newest first
    } else {
      orders[index] = order;
    }

    // 🔽 newest → oldest
    orders.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
  }

  // ---------------------------------------------------------------------------
  // ✅ UPDATE ORDER STATUS (Firebase ONLY – same name)
  // ---------------------------------------------------------------------------
  // Future<void> updateOrderStatus({
  //   required OrderModel order,
  //   required String newStatus,
  // }) async {
  //   final updatedOrder = order.copyWith(status: newStatus);
  //
  //   await FirebaseDatabase.instance
  //       .ref("orders/${order.key}")
  //       .update(updatedOrder.toJson());
  //   // 🔥 UI will update automatically via realtime listener
  // }

  Future<void> updateOrderStatus({
    required OrderModel order,
    required String newStatus,
  }) async {
    await OrderStatusService.updateOrderStatus(
      order: order,
      newStatus: newStatus,
      onSave: (updatedOrder) async {
        // 🔥 حفظ في Firebase فقط
        await FirebaseDatabase.instance
            .ref("orders/${updatedOrder.key}")
            .update(updatedOrder.toJson());
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 🔄 PULL TO REFRESH (same name – noop)
  // ---------------------------------------------------------------------------
  Future<void> refreshAll() async {
    // Realtime already active → nothing to do
    return;
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------
  @override
  void onClose() {
    _addSub?.cancel();
    _changeSub?.cancel();
    _removeSub?.cancel();
    super.onClose();
  }
}
