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

  // ============================================================
  // 🌊 STREAM CONTROLLERS (Expose to upper layers)
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
  // 🎧 REALTIME SYNC (Firebase → SQLite → Streams)
  // ============================================================

  @override
  Future<void> startListening({required String doctorKey}) async {
    log("🎧 Start Listening Reservations → doctor: $doctorKey");

    _processedKeys.clear();
    await _remote.startListening(doctorKey: doctorKey);

    _addedSub = _remote.onAdded.listen((model) async {
      final key = model.key;
      if (key == null) return;

      if (_processedKeys.contains(key)) {
        log("⚠️ Duplicate Ignored → $key");
        return;
      }

      _processedKeys.add(key);

      log("🔥 Firebase Added → $key");
      await _local.upsertFromServer(model);
      log("💾 Saved To SQLite → $key");

      // ✅ Forward event
      _addedController.add(model);
    });

    _changedSub = _remote.onChanged.listen((model) async {
      final key = model.key;
      if (key == null) return;

      log("🔄 Firebase Changed → $key");
      await _local.upsertFromServer(model);
      log("💾 SQLite Updated → $key");

      // ✅ Forward event
      _changedController.add(model);
    });

    _removedSub = _remote.onRemoved.listen((key) async {
      log("❌ Firebase Removed → $key");
      await _local.deleteReservation(key);
      log("💾 SQLite Deleted → $key");

      // ✅ Forward event
      _removedController.add(key);
    });
  }

  // ============================================================
  // 🛑 STOP REALTIME
  // ============================================================

  @override
  Future<void> dispose() async {
    log("🛑 Stop Listening Reservations");

    _processedKeys.clear();

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    await _remote.stopListening();

    await _addedController.close();
    await _changedController.close();
    await _removedController.close();
  }

  // ============================================================
  // 📦 GET (LOCAL ONLY)
  // ============================================================

  @override
  Future<Either<AppError, List<ReservationModel?>>> getReservationsDomain(
    SQLiteQueryParams query,
  ) async {
    try {
      log("📦 Fetch Reservations From SQLite");

      final result = await _local.getReservations(query);

      log("📦 SQLite Result Count → ${result.length}");

      return Right(result);
    } catch (e) {
      log("❌ SQLite Fetch Error → $e");
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
      log("➕ Add Reservation → ${model.key}");

      await _local.addReservation(model);

      if (await _connectivity.isOnline()) {
        await _remote.createReservation(model);

        await _local.markAsSynced(
          model.key!,
          serverUpdatedAt: DateTime.now().millisecondsSinceEpoch,
        );
      }

      return const Right(unit);
    } catch (e) {
      log("❌ Add Error → $e");
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

      if (await _connectivity.isOnline()) {
        await _remote.updateReservation(model);

        await _local.markAsSynced(
          model.key!,
          serverUpdatedAt: DateTime.now().millisecondsSinceEpoch,
        );
      }

      return const Right(unit);
    } catch (e) {
      log("❌ Update Error → $e");
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

      if (await _connectivity.isOnline()) {
        await _remote.deleteReservation(model);

        await _local.markAsSynced(
          key,
          serverUpdatedAt: DateTime.now().millisecondsSinceEpoch,
        );
      }

      return const Right(unit);
    } catch (e) {
      log("❌ Delete Error → $e");
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // ⭐ PATIENT META
  // ============================================================

  @override
  Future<Either<AppError, SuccessModel>> addPatientReservationMetaDomain(
    ReservationModel meta,
    String patientKey,
  ) async {
    try {
      final result = await _local.addPatientReservationMeta(meta, patientKey);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updatePatientReservationDomain(
    ReservationModel meta,
    String key,
  ) async {
    try {
      final result = await _local.updatePatientReservation(meta, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, List<ReservationModel>>>
  getPatientReservationsMetaDomain(String patientKey) async {
    try {
      final result = await _local.getPatientReservationsMeta(patientKey);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
