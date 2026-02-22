// ignore_for_file: avoid_renaming_method_parameters

import '../../../index/index_main.dart';

class OrderService {
  final OrderUseCases useCase = initController(() => OrderUseCases(Get.find()));

  // ===========================================================================
  // ➕ ADD NEW ORDER (WITH OPTIONAL SIDE EFFECTS)
  // ===========================================================================
  Future<void> addOrderData({
    required OrderModel order,
    OrderSideEffects? sideEffects,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.addOrder(order);

    await result.fold(
      (l) async {
        voidCallBack(ResponseStatus.error);
      },
      (r) async {
        // 🔔 Trigger side effects AFTER success
        if (sideEffects != null) {
          await _handleSideEffects(order: order, effects: sideEffects);
        }

        voidCallBack(ResponseStatus.success);
      },
    );
  }

  // ===========================================================================
  // 🔁 UPDATE ORDER
  // ===========================================================================
  Future<void> updateOrderData({
    required OrderModel order,
    OrderSideEffects? sideEffects,
    String? reason,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final result = await useCase.updateOrder(order);

    await result.fold(
      (l) async {
        Loader.dismiss();
        voidCallBack(ResponseStatus.error);
      },
      (r) async {
        Loader.dismiss();

        // 🔥 side effects (optional)
        if (sideEffects != null) {
          await _handleSideEffects(order: order, effects: sideEffects);
        }

        voidCallBack(ResponseStatus.success);
      },
    );
  }

  // ===========================================================================
  // 🗑️ DELETE ORDER
  // ===========================================================================
  Future<void> deleteOrderData({
    required String orderKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final result = await useCase.deleteOrder(orderKey);

    result.fold(
      (l) {
        Loader.dismiss();
        voidCallBack(ResponseStatus.error);
      },
      (r) {
        Loader.dismiss();
        voidCallBack(ResponseStatus.success);
      },
    );
  }

  // ===========================================================================
  // 📥 GET ORDERS
  // ===========================================================================
  Future<void> getOrdersData({
    required Map<String, dynamic> data,
    required FirebaseFilter filrebaseFilter,
    bool? isFiltered,
    required Function(List<OrderModel?>) voidCallBack,
  }) async {
    final result = await useCase.getOrders(
      filrebaseFilter.toJson(),
      isFiltered,
    );

    result.fold(
      (l) => Loader.showError("Something went wrong while fetching orders"),
      (r) => voidCallBack(r),
    );
  }

  // ===========================================================================
  // 🔒 INTERNAL: HANDLE SIDE EFFECTS (NOTIFICATION + WHATSAPP)
  // ===========================================================================
  Future<void> _handleSideEffects({
    required OrderModel order,
    required OrderSideEffects effects,
  }) async {
    final reservation = effects.reservation;
    final pharmacy = effects.pharmacy;

    // ───────────────── 🔔 NOTIFICATION ─────────────────
    if (effects.sendNotification && pharmacy != null && reservation != null) {

      await NotificationHandler().sendToClinicAssistants(
        title: "💊 طلب روشتة جديد",
        body: "طلب جديد من ${order.patientName}",
        reservation: reservation,
        assistants: [pharmacy],
        notificationType: "new_pharmacy_order",
      );
    }

    // ───────────────── 💬 WHATSAPP ─────────────────
    if (pharmacy != null) {
      await WhatsAppOrderMessageService.sendNewOrderMessage(order: order);
    }
  }
}

class OrderSideEffects {
  final bool sendNotification;
  final bool sendWhatsApp;

  final LocalUser? pharmacy;
  final ReservationModel? reservation;

  const OrderSideEffects({
    this.sendNotification = false,
    this.sendWhatsApp = false,
    this.pharmacy,
    this.reservation,
  });
}
