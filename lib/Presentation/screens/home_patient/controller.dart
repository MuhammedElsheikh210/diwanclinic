import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:diwanclinic/index/index_main.dart';

class HomePatientController extends GetxController {
  // 🔥 ORDERS (Realtime)
  RxList<OrderModel> orders = <OrderModel>[].obs;

  // 🔄 Firebase listeners
  StreamSubscription<DatabaseEvent>? _addSub;
  StreamSubscription<DatabaseEvent>? _changeSub;
  StreamSubscription<DatabaseEvent>? _removeSub;

  // 🧠 Other data
  final reservationVM = initController(() => ReservationPatientViewModel());

  List<CategoryEntity?>? listCategories;
  List<ReservationModel?>? listReservation;

  bool isLoading = false;

  final List<String> priorityKeys = [
    "d5508360-6780-4a1a-91c2-3b419c0fbdd3",
    "d66efe20-81a5-4df7-b6fb-07e5eae85465",
    "f9a3b6bf-c5db-4592-85c6-f14bc59fb0dd",
    "a92f4b3e-998b-4cb9-9d8c-ff924ba2c77b",
    "aa950b98-f49f-4290-ab82-bd1e8fbab411",
    "c09e07c9-ced7-4c1d-8e2b-47834e205d39",
    "c27f91dd-0b5f-4b6d-9c55-0b1cd8e01409",
  ];

  List<ReservationModel?> get activeReservations {
    return reservationVM.otherReservations;
  }

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

  // ------------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  // ------------------------------------------------------------------
  Future<void> _loadInitialData() async {
    isLoading = true;
    update();

    // reservations (not realtime yet)
    listReservation = await reservationVM.loadMyReservations();

    // 🔥 realtime orders
    fetchOrders();

    // categories
    getSpecializationData();

    isLoading = false;
    update();
  }

  // ------------------------------------------------------------------
  // 📥 FETCH ORDERS (REALTIME – same name)
  // ------------------------------------------------------------------
  Future<void> fetchOrders() async {
    final patientKey = LocalUser().getUserData().key;

    if (patientKey == null || patientKey.isEmpty) return;

    final ref = FirebaseDatabase.instance.ref("orders");

    // 🟢 ADD
    _addSub = ref.onChildAdded.listen((event) {
      if (event.snapshot.value == null) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      if (data["patient_key"] != patientKey) return;

      final order = OrderModel.fromJson(data);
      _upsertOrder(order);
      update();
    });

    // 🔄 UPDATE
    _changeSub = ref.onChildChanged.listen((event) {
      if (event.snapshot.value == null) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      if (data["patient_key"] != patientKey) return;

      final order = OrderModel.fromJson(data);
      _upsertOrder(order);
      update();
    });

    // ❌ REMOVE
    _removeSub = ref.onChildRemoved.listen((event) {
      if (event.snapshot.value == null) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      final removedKey = data["key"];
      orders.removeWhere((o) => o.key == removedKey);
      update();
    });
  }

  // ------------------------------------------------------------------
  // 🔁 ADD / UPDATE IN MEMORY
  // ------------------------------------------------------------------
  void _upsertOrder(OrderModel order) {
    final index = orders.indexWhere((o) => o.key == order.key);

    if (index == -1) {
      orders.insert(0, order);
    } else {
      orders[index] = order;
    }

    orders.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
  }

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

  // ------------------------------------------------------------------
  // CATEGORIES (unchanged)
  // ------------------------------------------------------------------
  void getSpecializationData() {
    CategoryService().getAllCategoriesData(
      voidCallBack: (data) {
        listCategories = data;

        listCategories!.sort((a, b) {
          final aIndex = priorityKeys.indexOf(a?.key ?? "");
          final bIndex = priorityKeys.indexOf(b?.key ?? "");

          if (aIndex != -1 && bIndex != -1) {
            return aIndex.compareTo(bIndex);
          }
          if (aIndex != -1) return -1;
          if (bIndex != -1) return 1;
          return (a?.name ?? "").compareTo(b?.name ?? "");
        });

        update();
      },
    );
  }

  // ------------------------------------------------------------------
  // 🔄 REFRESH (same name – partial reload)
  // ------------------------------------------------------------------
  Future<void> refreshAll() async {
    isLoading = true;
    update();

    reservationVM.getReservations(); // 🔥 دي المهمة

    getSpecializationData();

    isLoading = false;
    update();
  }

  // ------------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------------
  @override
  void onClose() {
    _addSub?.cancel();
    _changeSub?.cancel();
    _removeSub?.cancel();
    super.onClose();
  }
}
