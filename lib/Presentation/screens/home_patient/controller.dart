import 'dart:async';
import 'package:diwanclinic/index/index_main.dart';

class HomePatientController extends GetxController {
  // ============================================================
  // 🔥 ORDERS (Controlled from MainPageViewModel 🔥)
  // ============================================================

  RxList<OrderModel> orders = <OrderModel>[].obs;

  // ❌ شيلنا الـ service والـ subscriptions من هنا

  // ============================================================
  // 🧠 RESERVATIONS
  // ============================================================

  late final ReservationPatientViewModel reservationVM;

  List<CategoryEntity?>? listCategories;

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

  // ============================================================
  // 📊 GETTERS
  // ============================================================

  List<ReservationModel?> get activeReservations =>
      reservationVM.otherReservations;

  List<OrderModel> get activeOrders =>
      orders
          .where((o) => o.status != "delivered" && o.status != "cancelled")
          .toList();

  List<OrderModel> get finishedOrders =>
      orders
          .where((o) => o.status == "delivered" || o.status == "cancelled")
          .toList();

  // ============================================================
  // 🚀 INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    reservationVM = Get.find<ReservationPatientViewModel>();

    _loadInitialData();
  }

  // ============================================================
  // 🔄 REFRESH
  // ============================================================

  Future<void> refreshAll() async {
    isLoading = true;
    update();

    orders.clear();
    orders.refresh();

    getSpecializationData();

    isLoading = false;
    update();
  }

  // ============================================================
  Future<void> _loadInitialData() async {
    isLoading = true;
    update();

    getSpecializationData();

    isLoading = false;
    update();
  }

  // ============================================================
  // 🔁 UPSERT (🔥 أهم فانكشن)
  // ============================================================

  void upsertOrder(OrderModel order) {
    final index = orders.indexWhere((o) => o.key == order.key);

    if (index == -1) {
      orders.insert(0, order);
    } else {
      orders[index] = order;
    }

    orders.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    orders.refresh();
    update();
  }

  // ============================================================
  // 🔄 UPDATE STATUS
  // ============================================================

  Future<void> updateOrderStatus({
    required OrderModel order,
    required String newStatus,
  }) async {
    final service = initController(()=> PatientOrderService());
    await service.updateOrderData(
      order: order.copyWith(status: newStatus),
      voidCallBack: (_) {},
    );
  }

  // ============================================================
  // 🏷️ CATEGORIES
  // ============================================================

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

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  @override
  void onClose() {
    super.onClose();
  }
}
