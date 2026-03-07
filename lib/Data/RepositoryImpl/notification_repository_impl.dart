import 'dart:async';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remote;

  NotificationRepositoryImpl(this._remote);

  StreamSubscription? _addedSub;
  StreamSubscription? _changedSub;
  StreamSubscription? _removedSub;

  // ============================================================
  // 🌊 STREAM CONTROLLERS (Expose to ViewModel)
  // ============================================================

  final _addedController = StreamController<NotificationModel>.broadcast();
  final _changedController = StreamController<NotificationModel>.broadcast();
  final _removedController = StreamController<String>.broadcast();

  @override
  Stream<NotificationModel> get onAdded => _addedController.stream;

  @override
  Stream<NotificationModel> get onChanged => _changedController.stream;

  @override
  Stream<String> get onRemoved => _removedController.stream;

  // ============================================================
  // 🎧 REALTIME (Firebase → Streams Only)
  // ============================================================

  @override
  Future<void> startListening() async {
    log("🎧 Start Listening Notifications");

    await _remote.startListening();

    _addedSub?.cancel();
    _changedSub?.cancel();
    _removedSub?.cancel();

    _addedSub = _remote.onAdded.listen((model) {
      log("🔔 Notification Added → ${model.key}");
      _addedController.add(model);
    });

    _changedSub = _remote.onChanged.listen((model) {
      log("🔄 Notification Updated → ${model.key}");
      _changedController.add(model);
    });

    _removedSub = _remote.onRemoved.listen((key) {
      log("❌ Notification Removed → $key");
      _removedController.add(key);
    });
  }

  // ============================================================
  // 🛑 STOP REALTIME
  // ============================================================

  @override
  Future<void> dispose() async {
    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    await _remote.stopListening();

    if (!_addedController.isClosed) await _addedController.close();
    if (!_changedController.isClosed) await _changedController.close();
    if (!_removedController.isClosed) await _removedController.close();
  }

  // ============================================================
  // 🌐 FETCH NOTIFICATIONS (ONLINE ONLY)
  // ============================================================

  @override
  Future<Either<AppError, List<NotificationModel>>> fetchNotificationsDomain(
    Map<String, dynamic> firebaseFilter,
  ) async {
    try {
      final list = await _remote.fetchNotifications(firebaseFilter);
      return Right(list);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // ➕ CREATE NOTIFICATION
  // ============================================================

  @override
  Future<Either<AppError, Unit>> createNotificationDomain(
    NotificationModel model,
  ) async {
    try {
      await _remote.createNotification(model);
      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // 🔄 UPDATE NOTIFICATION
  // ============================================================

  @override
  Future<Either<AppError, Unit>> updateNotificationDomain(
    NotificationModel model,
  ) async {
    try {
      await _remote.updateNotification(model);
      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // ❌ DELETE NOTIFICATION
  // ============================================================

  @override
  Future<Either<AppError, Unit>> deleteNotificationDomain(String key) async {
    try {
      await _remote.deleteNotification(key);
      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
