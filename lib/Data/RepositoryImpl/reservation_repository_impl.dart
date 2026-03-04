import 'dart:developer';
import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationDataSourceRepo _local;
  final ReservationRemoteDataSource _remote;
  final ConnectivityService _connectivity;

  ReservationRepositoryImpl(this._local, this._remote, this._connectivity);

  // ============================================================
  // 🔥 REALTIME LISTENER
  // ============================================================
  final Set<String> _processedKeys = {};
  @override
  void startListening({
    required String doctorKey,
    required String date,
    required Function(ReservationModel model) onChanged,
    required Function(String key) onRemoved,
  }) {
    log("🎧 Start Listening Reservations → doctor: $doctorKey");
    _processedKeys.clear();
    _remote.listenToReservations(
      doctorKey: doctorKey,
      date: date,

      // ========================================================
      // ➕ ADDED FROM FIREBASE
      // ========================================================

      onAdded: (model) async {
        if (model.key == null) return;

        if (_processedKeys.contains(model.key)) {
          log("⚠️ Duplicate Event Ignored → ${model.key}");
          return;
        }

        _processedKeys.add(model.key!);

        log("🔥 Firebase Added → ${model.key}");

        await _local.upsertFromServer(model);

        log("💾 Saved To SQLite → ${model.key}");

        onChanged(model);
      },

      // ========================================================
      // 🔄 CHANGED FROM FIREBASE
      // ========================================================

      onChanged: (model) async {
        if (model.key == null) return;

        log("🔄 Firebase Changed → ${model.key}");

        await _local.upsertFromServer(model);

        log("💾 SQLite Updated → ${model.key}");

        onChanged(model);
      },

      // ========================================================
      // ❌ REMOVED FROM FIREBASE
      // ========================================================

      onRemoved: (key) async {
        log("❌ Firebase Removed → $key");

        await _local.deleteReservation(key);

        log("💾 SQLite Deleted → $key");

        onRemoved(key);
      },
    );
  }

  @override
  void dispose() {
    log("🛑 Stop Listening Reservations");
    _processedKeys.clear();
    _remote.stopListening();
  }

  // ============================================================
  // 📦 GET (Always From Local)
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
  // ➕ CREATE (Offline First + Instant Remote If Online)
  // ============================================================

  @override
  Future<Either<AppError, Unit>> addReservationDomain(
      ReservationModel model,
      ) async {
    try {
      log("➕ Add Reservation → ${model.key}");

      // 1️⃣ Save Locally First
      await _local.addReservation(model);

      log("💾 Saved Locally → ${model.key}");

      // 2️⃣ If Online → Push Immediately
      if (await _connectivity.isOnline()) {
        log("🌐 Internet Available → Push To Firebase");

        await _remote.createReservation(model);

        await _local.markAsSynced(
          model.key!,
          serverUpdatedAt: DateTime.now().millisecondsSinceEpoch,
        );

        log("☁️ Synced With Firebase → ${model.key}");
      } else {
        log("📴 Offline → Will Sync Later");
      }

      return const Right(unit);
    } catch (e) {
      log("❌ Add Reservation Error → $e");
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
      log("🔄 Update Reservation → ${model.key}");

      await _local.updateReservation(model);

      log("💾 SQLite Updated → ${model.key}");

      if (await _connectivity.isOnline()) {
        log("🌐 Internet Available → Update Firebase");

        await _remote.updateReservation(model);

        await _local.markAsSynced(
          model.key!,
          serverUpdatedAt: DateTime.now().millisecondsSinceEpoch,
        );

        log("☁️ Firebase Updated → ${model.key}");
      } else {
        log("📴 Offline → Update Pending Sync");
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
      log("❌ Delete Reservation → $key");

      final all = await _local.getReservations(
        SQLiteQueryParams(where: "key = ?", whereArgs: [key]),
      );

      final model = all.firstOrNull;
      if (model == null) {
        log("⚠️ Reservation Not Found In SQLite → $key");
        return const Right(unit);
      }

      await _local.deleteReservation(key);

      log("💾 SQLite Soft Delete → $key");

      if (await _connectivity.isOnline()) {
        log("🌐 Internet Available → Delete Firebase");

        await _remote.deleteReservation(model);

        await _local.markAsSynced(
          key,
          serverUpdatedAt: DateTime.now().millisecondsSinceEpoch,
        );

        log("☁️ Firebase Deleted → $key");
      } else {
        log("📴 Offline → Delete Pending Sync");
      }

      return const Right(unit);
    } catch (e) {
      log("❌ Delete Error → $e");
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // ⭐ PATIENT META (Remote Only)
  // ============================================================

  @override
  Future<Either<AppError, SuccessModel>> addPatientReservationMetaDomain(
      ReservationModel meta,
      String patientKey,
      ) async {
    try {
      log("⭐ Add Patient Reservation Meta");

      final result = await _local.addPatientReservationMeta(meta, patientKey);

      return Right(result);
    } catch (e) {
      log("❌ Add Patient Meta Error → $e");
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updatePatientReservationDomain(
      ReservationModel meta,
      String key,
      ) async {
    try {
      log("⭐ Update Patient Reservation Meta");

      final result = await _local.updatePatientReservation(meta, key);

      return Right(result);
    } catch (e) {
      log("❌ Update Patient Meta Error → $e");
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, List<ReservationModel>>>
  getPatientReservationsMetaDomain(String patientKey) async {
    try {
      log("⭐ Fetch Patient Reservations Meta");

      final result = await _local.getPatientReservationsMeta(patientKey);

      log("⭐ Patient Reservations Count → ${result.length}");

      return Right(result);
    } catch (e) {
      log("❌ Fetch Patient Meta Error → $e");
      return Left(AppError(e.toString()));
    }
  }
}