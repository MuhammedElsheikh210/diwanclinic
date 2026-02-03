import 'package:dartz/dartz.dart';
import 'package:diwanclinic/Data/data_source/notification_data_source_repo.dart';
import 'package:diwanclinic/Domain/Repositories/notification_repository.dart';
import '../../index/index_main.dart';

class NotificationRepositoryImpl extends NotificationRepository {
  final NotificationDataSourceRepo _notificationDataSourceRepo;

  NotificationRepositoryImpl(this._notificationDataSourceRepo);

  // ─────────────────────────────────────────────
  // 📥 Get All Notifications
  // ─────────────────────────────────────────────
  @override
  Future<Either<AppError, List<NotificationModel?>>> getNotificationsDomain(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      final result = await _notificationDataSourceRepo.getNotifications(
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
  // ➕ Add Notification
  // ─────────────────────────────────────────────
  @override
  Future<Either<AppError, SuccessModel>> addNotificationDomain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _notificationDataSourceRepo.addNotification(
        data,
        key,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  // 🗑️ Delete Notification
  // ─────────────────────────────────────────────
  @override
  Future<Either<AppError, SuccessModel>> deleteNotificationDomain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _notificationDataSourceRepo.deleteNotification(
        data,
        key,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  // 🔁 Update Notification
  // ─────────────────────────────────────────────
  @override
  Future<Either<AppError, SuccessModel>> updateNotificationDomain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _notificationDataSourceRepo.updateNotification(
        data,
        key,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
