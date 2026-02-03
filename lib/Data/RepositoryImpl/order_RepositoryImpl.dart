import 'package:dartz/dartz.dart';

import '../../index/index_main.dart';

class OrderRepositoryImpl extends OrderRepository {
  final OrderDataSourceRepo _orderDataSourceRepo;

  OrderRepositoryImpl(this._orderDataSourceRepo);

  // ─────────────────────────────────────────────
  // 📥 Get Orders
  // ─────────────────────────────────────────────
  @override
  Future<Either<AppError, List<OrderModel?>>> getOrdersDomain(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      final result = await _orderDataSourceRepo.getOrders(
        data,
        query,
        isFiltered,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  // ➕ Add Order
  // ─────────────────────────────────────────────
  @override
  Future<Either<AppError, SuccessModel>> addOrderDomain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _orderDataSourceRepo.addOrder(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  // 🔁 Update Order
  // ─────────────────────────────────────────────
  @override
  Future<Either<AppError, SuccessModel>> updateOrderDomain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _orderDataSourceRepo.updateOrder(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  // 🗑️ Delete Order
  // ─────────────────────────────────────────────
  @override
  Future<Either<AppError, SuccessModel>> deleteOrderDomain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _orderDataSourceRepo.deleteOrder(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
