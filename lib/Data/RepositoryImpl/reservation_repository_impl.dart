import 'dart:async';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationDataSourceRepo _local;
  final ReservationRemoteDataSource _remote;
  final ConnectivityService _connectivity;

  ReservationRepositoryImpl(this._local, this._remote, this._connectivity);

  final Set<String> _processedKeys = {};
  StreamSubscription? _addedSub;
  StreamSubscription? _changedSub;
  StreamSubscription? _removedSub;

  bool _isListening = false;




  // ============================================================
  // 🌊 STREAM CONTROLLERS
  // ============================================================

  final _addedController = StreamController<ReservationModel>.broadcast();
  final _changedController = StreamController<ReservationModel>.broadcast();
  final _removedController = StreamController<String>.broadcast();

  @override
  Stream<ReservationModel> get onAdded => _addedController.stream;

  @override
  Stream<ReservationModel> get onChanged => _changedController.stream;

  @override
  Stream<String> get onRemoved => _removedController.stream;

  // ============================================================
  // 🎧 REALTIME SYNC
  // ============================================================

  @override
  Future<void> startListening({required String doctorKey}) async {
    if (_isListening) {
      return;
    }


    _processedKeys.clear();

    await _remote.startListening(doctorKey: doctorKey);

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    _addedSub = _remote.onAdded.listen((model) async {
      final key = model.key;
      if (key == null) return;

      if (_processedKeys.contains(key)) return;
      _processedKeys.add(key);


      await _local.upsertFromServer(model);

      _addedController.add(model);

    });

    _changedSub = _remote.onChanged.listen((model) async {
      final key = model.key;
      if (key == null) return;


      await _local.upsertFromServer(model);

      _changedController.add(model);

    });

    _removedSub = _remote.onRemoved.listen((key) async {

      await _local.deleteReservation(key);

      _removedController.add(key);

    });

    _isListening = true;
  }

  // ============================================================
  // 🛑 STOP REALTIME
  // ============================================================

  @override
  Future<void> stopListening() async {
    log("🛑 Stop Reservations Realtime");

    _isListening = false;
    _processedKeys.clear();

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    await _remote.stopListening();
  }

  @override
  Future<void> dispose() async {
    log("🛑 Dispose Reservations");

    await stopListening();

    if (!_addedController.isClosed) await _addedController.close();
    if (!_changedController.isClosed) await _changedController.close();
    if (!_removedController.isClosed) await _removedController.close();
  }

  // ============================================================
  // 📦 GET (WAIT FOR INITIAL SYNC)
  // ============================================================

  @override
  Future<Either<AppError, List<ReservationModel?>>> getReservationsDomain(
    SQLiteQueryParams query,
  ) async {
    try {


      final result = await _local.getReservations(query);


      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // ➕ CREATE (Offline First)
  // ============================================================

  @override
  Future<Either<AppError, Unit>> addReservationDomain(
    ReservationModel model,
  ) async {
    try {
      await _local.addReservation(model);
        await _remote.createReservation(model);

        // await _local.markAsSynced(
        //   model.key!,
        //   serverUpdatedAt: DateTime.now().millisecondsSinceEpoch,
        // );


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
      await _local.updateReservation(model);

        await _remote.updateReservation(model);

        // await _local.markAsSynced(
        //   model.key!,
        //   serverUpdatedAt: DateTime.now().millisecondsSinceEpoch,
        // );


      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // ❌ DELETE
  // ============================================================

  @override
  Future<Either<AppError, Unit>> deleteReservationDomain(String key) async {
    try {
      final all = await _local.getReservations(
        SQLiteQueryParams(where: "key = ?", whereArgs: [key]),
      );

      final model = all.firstOrNull;
      if (model == null) return const Right(unit);

      await _local.deleteReservation(key);

        await _remote.deleteReservation(model);

        // await _local.markAsSynced(
        //   key,
        //   serverUpdatedAt: DateTime.now().millisecondsSinceEpoch,
        // );


      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // ⭐ PATIENT META
  // ============================================================

  // @override
  // Future<Either<AppError, SuccessModel>> addPatientReservationMetaDomain(
  //   ReservationModel meta,
  //   String patientKey,
  // ) async {
  //   try {
  //     final result = await _local.addPatientReservationMeta(meta, patientKey);
  //     return Right(result);
  //   } catch (e) {
  //     return Left(AppError(e.toString()));
  //   }
  // }
  //
  // @override
  // Future<Either<AppError, SuccessModel>> updatePatientReservationDomain(
  //   ReservationModel meta,
  //   String key,
  // ) async {
  //   try {
  //     final result = await _local.updatePatientReservation(meta, key);
  //     return Right(result);
  //   } catch (e) {
  //     return Left(AppError(e.toString()));
  //   }
  // }
  //
  // @override
  // Future<Either<AppError, List<ReservationModel>>>
  // getPatientReservationsMetaDomain(String patientKey) async {
  //   try {
  //     final result = await _local.getPatientReservationsMeta(patientKey);
  //     return Right(result);
  //   } catch (e) {
  //     return Left(AppError(e.toString()));
  //   }
  // }

// ============================================================
// 📥 PATIENT FETCH (REMOTE ONLY)
// ============================================================

  @override
  Future<Either<AppError, List<ReservationModel>>>
  fetchReservationsOnceDomain({
    required String doctorKey,
    required String date,
  }) async {
    try {

      final list = await _remote.fetchReservationsOnce(
        doctorKey: doctorKey,
        date: date,
      );


      return Right(list);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
