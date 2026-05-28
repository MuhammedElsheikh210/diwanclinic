import 'dart:async';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class PatientReservationRepositoryImpl implements PatientReservationRepository {
  final PatientReservationRemoteDataSource _remote;

  PatientReservationRepositoryImpl(this._remote) {
  }

  StreamSubscription? _addedSub;
  StreamSubscription? _changedSub;
  StreamSubscription? _removedSub;

  bool _isListening = false;

  final _addedController = StreamController<ReservationModel>.broadcast();
  final _changedController = StreamController<ReservationModel>.broadcast();
  final _removedController = StreamController<String>.broadcast();

  @override
  Stream<ReservationModel> get onAdded {
    return _addedController.stream;
  }

  @override
  Stream<ReservationModel> get onChanged {
    return _changedController.stream;
  }

  @override
  Stream<String> get onRemoved {
    return _removedController.stream;
  }

  // ============================================================
  // 🎧 REALTIME LISTEN
  // ============================================================

  @override
  Future<void> startListening({required String patientUid}) async {

    if (_isListening) {
      return;
    }

    await _remote.startListening(patientUid: patientUid);

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    void onError(Object error, StackTrace stack) {
      log("❌ PatientReservationRepo stream error: $error");
      _isListening = false;
    }

    _addedSub = _remote.onAdded.listen(
      (model) {
        if (model.key == null) return;
        _addedController.add(model);
      },
      onError: onError,
      cancelOnError: false,
    );

    _changedSub = _remote.onChanged.listen(
      (model) {
        if (model.key == null) return;
        _changedController.add(model);
      },
      onError: onError,
      cancelOnError: false,
    );

    _removedSub = _remote.onRemoved.listen(
      (key) => _removedController.add(key),
      onError: onError,
      cancelOnError: false,
    );

    _isListening = true;

  }

  // ============================================================
  // 🛑 STOP
  // ============================================================

  @override
  Future<void> stopListening() async {
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
  Future<void> dispose() async {

    await stopListening();

    if (!_addedController.isClosed) {
      await _addedController.close();
    }

    if (!_changedController.isClosed) {
      await _changedController.close();
    }

    if (!_removedController.isClosed) {
      await _removedController.close();
    }

  }

  // ============================================================
  // ➕ CREATE
  // ============================================================

  @override
  Future<Either<AppError, Unit>> addReservationDomain(
    ReservationModel model,
  ) async {

    try {
      await _remote.createReservation(model);
      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // 🔄 UPDATE
  // ============================================================

  @override
  Future<Either<AppError, Unit>> updateReservationDomain(
    ReservationModel model,
  ) async {

    try {
      await _remote.updateReservation(model);
      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // ❌ DELETE
  // ============================================================

  @override
  Future<Either<AppError, Unit>> deleteReservationDomain(
    ReservationModel model,
  ) async {

    try {
      await _remote.deleteReservation(model);
      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
