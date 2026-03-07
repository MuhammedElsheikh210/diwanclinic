import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class NotificationRepository {
  // ============================================================
  // 🔥 REALTIME CONTROL
  // ============================================================

  Future<void> startListening();

  Future<void> dispose();

  // ============================================================
  // 🔥 REALTIME STREAMS (Expose to upper layers)
  // ============================================================

  Stream<NotificationModel> get onAdded;

  Stream<NotificationModel> get onChanged;

  Stream<String> get onRemoved;

  // ============================================================
  // 🌐 ONLINE NOTIFICATIONS (Firebase Direct)
  // ============================================================

  Future<Either<AppError, List<NotificationModel>>> fetchNotificationsDomain(
      Map<String, dynamic> firebaseFilter,
      );

  Future<Either<AppError, Unit>> createNotificationDomain(
      NotificationModel model,
      );

  Future<Either<AppError, Unit>> updateNotificationDomain(
      NotificationModel model,
      );

  Future<Either<AppError, Unit>> deleteNotificationDomain(
      String key,
      );
}