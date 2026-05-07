import 'package:dartz/dartz.dart';

import '../../../index/index_main.dart';

class OrderUseCases {
  final OrderRepository _repository;

  OrderUseCases(this._repository);

  // ============================================================
  // 🔥 REALTIME CONTROL
  // ============================================================

  Future<void> startListening() {
    return _repository.startListening();
  }

  Future<void> dispose() {
    return _repository.dispose();
  }

  Stream<OrderModel> get onAdded => _repository.onAdded;

  Stream<OrderModel> get onChanged => _repository.onChanged;

  Stream<String> get onRemoved => _repository.onRemoved;

  // ============================================================
  // 🌐 FETCH
  // ============================================================

  Future<Either<AppError, List<OrderModel>>>
  fetchAllOrders() {
    return _repository.fetchAllOrdersDomain();
  }

  Future<Either<AppError, List<OrderModel?>>> getOrders(
      Map<String, dynamic> data,
      bool? isFiltered,
      ) {
    return _repository.getOrdersDomain(
      data,
      SQLiteQueryParams(),
      isFiltered,
    );
  }

  // ============================================================
  // ➕ ADD
  // ============================================================

  Future<Either<AppError, SuccessModel>> addOrder(
      OrderModel order,
      ) {
    return _repository.addOrderDomain(
      order.toJson(),
      order.key ?? "",
    );
  }

  // ============================================================
  // 🔄 UPDATE
  // ============================================================

  Future<Either<AppError, SuccessModel>> updateOrder(
      OrderModel order,
      ) {
    return _repository.updateOrderDomain(
      order.toJson(),
      order.key ?? "",
    );
  }

  // ============================================================
  // ❌ DELETE
  // ============================================================

  Future<Either<AppError, SuccessModel>> deleteOrder(
      String key,
      ) {
    return _repository.deleteOrderDomain({}, key);
  }
}