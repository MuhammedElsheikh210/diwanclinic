import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class OrderRepository {

  // ============================================================
  // 🔥 REALTIME CONTROL
  // ============================================================

  Future<void> startListening();

  Future<void> dispose();

  // ============================================================
  // 🔥 REALTIME STREAMS
  // ============================================================

  Stream<OrderModel> get onAdded;

  Stream<OrderModel> get onChanged;

  Stream<String> get onRemoved;

  // ============================================================
  // 🌐 FETCH
  // ============================================================

  Future<Either<AppError, List<OrderModel?>>> getOrdersDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  /// 🔥 NEW
  Future<Either<AppError, List<OrderModel>>>
  fetchAllOrdersDomain();

  // ============================================================
  // CRUD
  // ============================================================

  Future<Either<AppError, SuccessModel>> addOrderDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> updateOrderDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> deleteOrderDomain(
      Map<String, dynamic> data,
      String key,
      );
}