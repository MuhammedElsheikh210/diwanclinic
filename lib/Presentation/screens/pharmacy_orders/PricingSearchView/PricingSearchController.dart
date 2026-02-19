import 'dart:async';
import 'package:diwanclinic/Presentation/parentControllers/MedicineService.dart';
import '../../../../index/index_main.dart';

class PricingSearchController extends GetxController {
  // ───────────── Controllers ─────────────
  final TextEditingController searchController = TextEditingController();

  // ───────────── Search State ─────────────
  bool isLoading = false;
  List<MedicineModel> searchResults = [];

  Timer? _debounce;

  // ───────────── Selected Medicines ─────────────
  List<SelectedMedicine> selectedMedicines = [];

  // ───────────── Pricing ─────────────
  double discountPercent = 0.0;
  double deliveryFee = 15;

  // subtotal already num → نخليه int
  int get subtotalInt =>
      selectedMedicines.fold<int>(0, (s, e) => s + e.total.round());

  // الخصم يتقرب لأقرب عدد صحيح
  int get discountValueInt => (subtotalInt * discountPercent).round();

  // التوصيل عدد صحيح
  int get deliveryFeeInt => deliveryFee.round();

  // الإجمالي النهائي
  int get totalInt => subtotalInt - discountValueInt + deliveryFeeInt;

  void initWithOrder(OrderModel order) {
    // 🎯 لو تابع كشف
    if (order.reservationKey != null && order.reservationKey!.isNotEmpty) {
      discountPercent = 0.05; // 5%
    } else {
      discountPercent = 0.10; // 10% (Free)
    }

    update();
  }

  // ───────────── Search Logic (PRODUCTION) ─────────────
  void onSearchChanged(String value) {
    final keyword = value.trim();

    // ⛔ Ignore short keywords
    if (keyword.length < 2) {
      _debounce?.cancel();
      searchResults.clear();
      isLoading = false;
      update();
      return;
    }

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 200), () async {
      isLoading = true;
      update();


      try {
        await MedicineService().searchMedicinesData(
          keyword: keyword,
          voidCallBack: (data) {
            searchResults = data;
            isLoading = false;
            update();
          },
        );
      } catch (_) {
        // ❗ Search error ≠ critical error
        searchResults = [];
        isLoading = false;
        update();
      }
    });
  }

  // ───────────── Build Order Data ─────────────
  List<MedicineItemModel> buildMedicineItems() {
    return selectedMedicines.map((e) {
      return MedicineItemModel(
        key: e.medicine.id.toString(),
        name: e.medicine.name,
        quantity: e.quantity,
        price: e.medicine.price,
      );
    }).toList();
  }

  OrderModel buildUpdatedOrder(OrderModel order) {
    return order.copyWith(
      medicines: buildMedicineItems(),
      totalOrder: subtotalInt,
      discount: discountValueInt,
      deliveryFees: deliveryFee,
      finalAmount: totalInt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  // ───────────── Quantity Controls ─────────────
  void increaseQty(SelectedMedicine item) {
    item.quantity++;
    update();
  }

  void decreaseQty(SelectedMedicine item) {
    if (item.quantity <= 1) return;
    item.quantity--;
    update();
  }

  // ───────────── Add Medicine ─────────────
  void addMedicine(MedicineModel medicine) {
    final index = selectedMedicines.indexWhere(
      (e) => e.medicine.id == medicine.id,
    );

    searchResults.clear();
    searchController.clear();
    FocusManager.instance.primaryFocus?.unfocus();

    if (index == -1) {
      selectedMedicines.add(SelectedMedicine(medicine: medicine));
    } else {
      selectedMedicines[index].quantity++;
    }

    update();
  }

  // ───────────── Save Pricing ─────────────
  Future<void> updateOrderStatus({required OrderModel order}) async {
    final updatedOrder = buildUpdatedOrder(order);

    await OrderStatusService.updateOrderStatus(
      order: updatedOrder,
      newStatus: "calculated",
      onSave: (savedOrder) async {
        await OrderService().updateOrderData(
          order: savedOrder,
          voidCallBack: (_) async {
            final controller = Get.isRegistered<PharmacyOrdersListViewModel>()
                ? Get.find<PharmacyOrdersListViewModel>()
                : initController(() => PharmacyOrdersListViewModel());

            await controller.fetchOrders();
            controller.update();
            Get.back();
          },
        );
      },
    );
  }

  // ───────────── Pricing Controls ─────────────
  void setDiscount(double value) {
    discountPercent = value;
    update();
  }

  void setDelivery(double value) {
    deliveryFee = value;
    update();
  }

  // ───────────── Lifecycle ─────────────
  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}

class SelectedMedicine {
  final MedicineModel medicine;
  int quantity;
  double price;

  SelectedMedicine({
    required this.medicine,
    this.quantity = 1,
  }) : price = (medicine.price ?? 0).toDouble();

  double get total => price * quantity;
}
