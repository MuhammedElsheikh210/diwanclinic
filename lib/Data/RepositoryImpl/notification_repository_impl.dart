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

  bool _isListening = false;

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
    if (_isListening) {
      await stopListening();
    }

    await _remote.startListening();

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    void onStreamError(Object error, StackTrace stack) {
      // Don't reset _isListening — Firebase reconnects internally (cancelOnError: false)
      AppLogger.error("NOTIFICATION_REPO", "Stream error", error, stack);
    }

    _addedSub = _remote.onAdded.listen(
      (model) {
        if (!_addedController.isClosed) _addedController.add(model);
      },
      onError: onStreamError,
      cancelOnError: false,
    );

    _changedSub = _remote.onChanged.listen(
      (model) {
        if (!_changedController.isClosed) _changedController.add(model);
      },
      onError: onStreamError,
      cancelOnError: false,
    );

    _removedSub = _remote.onRemoved.listen(
      (key) {
        if (!_removedController.isClosed) _removedController.add(key);
      },
      onError: onStreamError,
      cancelOnError: false,
    );

    _isListening = true;
    log("✅ Notification realtime initialized");
  }

  // ============================================================
  // 🛑 STOP REALTIME
  // ============================================================

  @override
  Future<void> stopListening() async {
    log("🛑 Stop Notification Realtime");

    _isListening = false;

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    _addedSub = null;
    _changedSub = null;
    _removedSub = null;

    await _remote.stopListening();
  }


  @override
  Future<Either<AppError, List<NotificationModel>>>
  fetchAllNotificationsDomain() async {
    try {
      final list = await _remote.fetchAllNotifications();
      return Right(list);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

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
