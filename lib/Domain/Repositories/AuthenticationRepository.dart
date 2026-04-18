import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class AuthenticationRepository {
  // ============================================================
  // 🔥 REALTIME CONTROL (Firebase → SQLite Sync Only)
  // ============================================================

  Future<void> startListening();

  Future<void> dispose();

  // ============================================================
  // 🔥 REALTIME STREAMS (Mapped to Domain)
  // ============================================================

  Stream<LocalUser> get onAdded;

  Stream<LocalUser> get onChanged;

  Stream<String> get onRemoved;

  // ============================================================
  // 🔹 LOCAL CLIENTS (Offline First)
  // ============================================================

  Future<Either<AppError, List<LocalUser>>> getClientsDomain(
      SQLiteQueryParams query,
      );

  Future<Either<AppError, Unit>> addClientDomain(LocalUser model);

  Future<Either<AppError, Unit>> updateClientDomain(LocalUser model);

  Future<Either<AppError, Unit>> deleteClientDomain(String key);

  // ============================================================
  // 🌐 ONLINE CLIENTS (Firebase Direct Fetch)
  // ============================================================

  /// Bulk fetch (used for sync / refresh)
  Future<Either<AppError, List<LocalUser>>> getClientsOnlineDomain(
      Map<String, dynamic> firebaseFilter,
      );

  /// ✅ NEW: Fetch single client (LOGIN / critical)
  Future<Either<AppError, LocalUser?>> getClientByUidOnlineDomain(
      String uid,
      );
}