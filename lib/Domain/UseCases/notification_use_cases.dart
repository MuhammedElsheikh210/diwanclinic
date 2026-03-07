import 'package:dartz/dartz.dart';
import 'package:diwanclinic/Domain/Repositories/notification_repository.dart';
import '../../../index/index_main.dart';

class NotificationUseCases {
  final NotificationRepository _repository;

  NotificationUseCases(this._repository);

  // ============================================================
  // 🔥 REALTIME CONTROL
  // ============================================================

  Future<void> startListening() {
    return _repository.startListening();
  }

  Future<void> dispose() {
    return _repository.dispose();
  }

  Stream<NotificationModel> get onAdded => _repository.onAdded;

  Stream<NotificationModel> get onChanged => _repository.onChanged;

  Stream<String> get onRemoved => _repository.onRemoved;

  // ============================================================
  // 🌐 FETCH (ONLINE)
  // ============================================================

  Future<Either<AppError, List<NotificationModel>>> fetchNotifications(
    Map<String, dynamic> firebaseFilter,
  ) {
    return _repository.fetchNotificationsDomain(firebaseFilter);
  }

  // ============================================================
  // ➕ CREATE
  // ============================================================

  Future<Either<AppError, Unit>> createNotification(
    NotificationModel notification,
  ) {
    return _repository.createNotificationDomain(notification);
  }

  // ============================================================
  // 🔄 UPDATE
  // ============================================================

  Future<Either<AppError, Unit>> updateNotification(
    NotificationModel notification,
  ) {
    return _repository.updateNotificationDomain(notification);
  }

  // ============================================================
  // ❌ DELETE
  // ============================================================

  Future<Either<AppError, Unit>> deleteNotification(String key) {
    return _repository.deleteNotificationDomain(key);
  }
}
