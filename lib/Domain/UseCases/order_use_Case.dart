import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class OrderUseCases {
  final OrderRepository _repository;

  OrderUseCases(this._repository);

  /// ➕ Add new order
  Future<Either<AppError, SuccessModel>> addOrder(OrderModel order) {
    return _repository.addOrderDomain(order.toJson(), order.key ?? "");
  }

  /// 🔁 Update existing order
  Future<Either<AppError, SuccessModel>> updateOrder(OrderModel order) {
    return _repository.updateOrderDomain(order.toJson(), order.key ?? "");
  }

  /// 🗑️ Delete order by key
  Future<Either<AppError, SuccessModel>> deleteOrder(String key) {
    return _repository.deleteOrderDomain({}, key);
  }

  /// 📥 Get list of orders (with filters)
  Future<Either<AppError, List<OrderModel?>>> getOrders(
      Map<String, dynamic> data,
      bool? isFiltered,
      ) {
    return _repository.getOrdersDomain(data, SQLiteQueryParams(), isFiltered);
  }
}
