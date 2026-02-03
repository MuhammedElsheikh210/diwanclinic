import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class NotificationRepository {
  /// 🔹 Get all or filtered notifications
  Future<Either<AppError, List<NotificationModel?>>> getNotificationsDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  /// 🔹 Add new notification
  Future<Either<AppError, SuccessModel>> addNotificationDomain(
      Map<String, dynamic> data,
      String key,
      );

  /// 🔹 Delete notification
  Future<Either<AppError, SuccessModel>> deleteNotificationDomain(
      Map<String, dynamic> data,
      String key,
      );

  /// 🔹 Update existing notification
  Future<Either<AppError, SuccessModel>> updateNotificationDomain(
      Map<String, dynamic> data,
      String key,
      );
}
