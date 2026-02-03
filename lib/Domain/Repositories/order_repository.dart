import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

/// 🧾 Domain Layer Repository Contract for Orders
/// Wraps DataSource calls with Either<AppError, T> for error handling.
abstract class OrderRepository {
  /// 🔹 Get all orders (with filtering support)
  Future<Either<AppError, List<OrderModel?>>> getOrdersDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  /// 🔹 Add new order
  Future<Either<AppError, SuccessModel>> addOrderDomain(
      Map<String, dynamic> data,
      String key,
      );

  /// 🔹 Update existing order
  Future<Either<AppError, SuccessModel>> updateOrderDomain(
      Map<String, dynamic> data,
      String key,
      );

  /// 🔹 Delete order
  Future<Either<AppError, SuccessModel>> deleteOrderDomain(
      Map<String, dynamic> data,
      String key,
      );
}
