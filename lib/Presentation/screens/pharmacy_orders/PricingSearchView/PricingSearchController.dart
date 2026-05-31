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
  double deliveryFee = 5;

  // Primary pharmacy account — has wallet/instapay even when a staff logs in
  PharmacyUser? _primaryPharmacy;

  // ───────────── Calculations ─────────────

  int get subtotalInt =>
      selectedMedicines.fold<int>(0, (s, e) => s + e.total.round());

  int get deliveryFeeInt => deliveryFee.round();

  int get totalInt => subtotalInt + deliveryFeeInt;

  Future<void> initWithOrder(OrderModel order) async {
    final sessionPharmacy = Get.find<UserSession>().user?.asPharmacy;
    final primaryId = sessionPharmacy?.pharmacyId ?? sessionPharmacy?.uid;

    if (primaryId != null && primaryId.isNotEmpty) {
      final completer = Completer<List<LocalUser?>>();
      AuthenticationService().getClientsData(
        query: SQLiteQueryParams(where: "uid = ?", whereArgs: [primaryId]),
        voidCallBack: (users) => completer.complete(users),
      );
      final users = await completer.future;
      _primaryPharmacy = users.firstOrNull?.asPharmacy;
    }

    update();
  }

  List<double> get availableDeliveryFees => [5, 10];

  void refreshDeliveryFee() {
    final options = availableDeliveryFees;

    if (!options.contains(deliveryFee)) {
      deliveryFee = options.first;
    }
  }

  // ───────────── Search Logic ─────────────
  void onSearchChanged(String value) {
    final keyword = value.trim();

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
        price: e.price,
        imported: e.medicine.imported,
      );
    }).toList();
  }

  OrderModel buildUpdatedOrder(OrderModel order) {
    final sessionPharmacy = Get.find<UserSession>().user?.asPharmacy;
    // Use primary pharmacy for payment info — staff accounts don't carry wallet/instapay
    final paymentSource = _primaryPharmacy ?? sessionPharmacy;
    return order.copyWith(
      medicines: buildMedicineItems(),
      totalOrder: subtotalInt,
      discount: 0,
      deliveryFees: deliveryFee,
      finalAmount: totalInt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      pharmacyKey: sessionPharmacy?.pharmacyId ?? sessionPharmacy?.uid,
      pharmacyWalletNumber: paymentSource?.walletNumber,
      pharmacyInstapayNumber: paymentSource?.instapayNumber,
      pharmacyInstapayLink: paymentSource?.instapayLink,
    );
  }

  // ───────────── Quantity Controls ─────────────

  void increaseQty(SelectedMedicine item) {
    item.quantity++;
    refreshDeliveryFee();

    update();
  }

  void decreaseQty(SelectedMedicine item, BuildContext context) {
    if (item.quantity > 1) {
      item.quantity--;
      refreshDeliveryFee();

      update();
      return;
    }

    // 👇 لو الكمية = 1 → نسأل قبل الحذف
    ActionDialogHelper.show(
      context: context,
      title: "حذف الدواء",
      message: "هل أنت متأكد من حذف هذا الدواء من الطلب؟",
      confirmText: "حذف",
      confirmColor: AppColors.errorForeground,
      onConfirm: () {
        selectedMedicines.remove(item);
        update();
      },
    );
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
    refreshDeliveryFee();
    update();
  }

  // ───────────── Save Pricing ─────────────
  Future<void> updateOrderStatus({required OrderModel order}) async {
    final updatedOrder = buildUpdatedOrder(order);

    // تحديث سعر كل دواء في قاعدة البيانات المحلية
    for (final item in selectedMedicines) {
      await MedicineService().updateMedicinePrice(
        id: item.medicine.id,
        price: item.price,
      );
    }

    await OrderStatusService.updateOrderStatus(
      order: updatedOrder,
      newStatus: "calculated",
      onSave: (savedOrder) async {
        await OrderService().updateOrderData(
          order: savedOrder,
          voidCallBack: (_) async {
            final controller =
                Get.isRegistered<PharmacyOrdersListViewModel>()
                    ? Get.find<PharmacyOrdersListViewModel>()
                    : initController(() => PharmacyOrdersListViewModel());

            // if (order.createdBy == "whatsapp") {
            //   await WhatsAppSessionService.markCalculated(
            //     phone: order.whatsApp ?? "",
            //     orderId: order.key ?? "",
            //   );
            // }

            await controller.fetchOrders();
            controller.update();
            Get.back();
          },
        );
      },
    );
  }

  // ───────────── Pricing Controls ─────────────
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

  SelectedMedicine({required this.medicine, this.quantity = 1})
    : price = (medicine.price ?? 0).toDouble();

  double get total => price * quantity;
}
