import '../../../index/index_main.dart';

class OrderService {
  final OrderUseCases useCase = initController(() => OrderUseCases(Get.find()));

  // ============================================================
  // 🎧 REALTIME CALLBACKS
  // ============================================================

  Function(OrderModel model)? onOrderAdded;
  Function(OrderModel model)? onOrderUpdated;
  Function(String key)? onOrderRemoved;

  StreamSubscription? _addedSub;
  StreamSubscription? _changedSub;
  StreamSubscription? _removedSub;

  bool _isListening = false;
  bool _isDisposed = false;

  // ============================================================
  // 🔥 START REALTIME LISTENING
  // ============================================================

  Future<void> startListening() async {
    /// ✅ already listening
    if (_isListening) {
      AppLogger.warning("ORDER", "Already listening → skip");
      return;
    }

    /// ❌ disposed
    if (_isDisposed) {
      AppLogger.error("ORDER", "Service already disposed ❌");
      return;
    }

    await useCase.startListening();

    // ============================================================
    // 🟢 ADDED
    // ============================================================

    _addedSub = useCase.onAdded.listen((model) {
      if (_isDisposed) return;

      onOrderAdded?.call(model);
    });

    // ============================================================
    // 🔄 UPDATED
    // ============================================================

    _changedSub = useCase.onChanged.listen((model) {
      if (_isDisposed) return;

      onOrderUpdated?.call(model);
    });

    // ============================================================
    // ❌ REMOVED
    // ============================================================

    _removedSub = useCase.onRemoved.listen((key) {
      if (_isDisposed) return;

      onOrderRemoved?.call(key);
    });

    _isListening = true;

    AppLogger.success("ORDER", "Listening started ✅");
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  Future<void> dispose() async {
    if (_isDisposed) return;

    _isListening = false;
    _isDisposed = true;

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    _addedSub = null;
    _changedSub = null;
    _removedSub = null;

    await useCase.dispose();

    AppLogger.warning("ORDER", "Service disposed 🛑");
  }

  // ============================================================
  // 🌐 FETCH ALL ORDERS
  // ============================================================

  Future<void> getAllOrdersOnlineData({
    required Function(List<OrderModel>) voidCallBack,
  }) async {
    final result = await useCase.fetchAllOrders();

    result.fold(
      (l) => Loader.showError("Network error while loading orders"),
      (r) => voidCallBack(r),
    );
  }

  // ===========================================================================
  // ➕ ADD NEW ORDER
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
        // 🔔 SIDE EFFECTS
        if (sideEffects != null) {
          await _handleSideEffects(order: order, effects: sideEffects);
        }

        voidCallBack(ResponseStatus.success);
      },
    );
  }

  // ===========================================================================
  // 🔄 UPDATE ORDER
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

        if (sideEffects != null) {
          await _handleSideEffects(order: order, effects: sideEffects);
        }

        voidCallBack(ResponseStatus.success);
      },
    );
  }

  // ===========================================================================
  // ❌ DELETE ORDER
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
  // 🔒 SIDE EFFECTS
  // ===========================================================================

  Future<void> _handleSideEffects({
    required OrderModel order,
    required OrderSideEffects effects,
  }) async {
    final reservation = effects.reservation;
    final pharmacy = effects.pharmacy;

    // ============================================================
    // 🔔 NOTIFICATION
    // ============================================================

    // if (effects.sendNotification && pharmacy != null && reservation != null) {
    //   await NotificationHandler().sendToClinicAssistants(
    //     title: "💊 طلب روشتة جديد",
    //     body: "طلب جديد من ${order.patientName}",
    //     reservation: reservation,
    //     assistants: [pharmacy],
    //     notificationType: "new_pharmacy_order",
    //   );
    // }

    // ============================================================
    // 💬 WHATSAPP
    // ============================================================

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
