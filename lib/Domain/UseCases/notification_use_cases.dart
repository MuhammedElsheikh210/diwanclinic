import 'package:dartz/dartz.dart';
import 'package:diwanclinic/Domain/Repositories/notification_repository.dart';
import '../../../index/index_main.dart';

class NotificationUseCases {
  final NotificationRepository _repository;

  NotificationUseCases(this._repository);

  Future<Either<AppError, SuccessModel>> addNotification(
    NotificationModel notification,
  ) {
    return _repository.addNotificationDomain(
      notification.toJson(),
      notification.key ?? "",
    );
  }

  Future<Either<AppError, SuccessModel>> updateNotification(
    NotificationModel notification,
  ) {
    return _repository.updateNotificationDomain(
      notification.toJson(),
      notification.key ?? "",
    );
  }

  Future<Either<AppError, SuccessModel>> deleteNotification(String key) {
    return _repository.deleteNotificationDomain({}, key);
  }

  Future<Either<AppError, List<NotificationModel?>>> getNotifications(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) {
    return _repository.getNotificationsDomain(data, query, isFiltered);
  }
}
