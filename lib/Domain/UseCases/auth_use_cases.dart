import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class AuthenticationUseCases {
  final AuthenticationRepository _repository;

  AuthenticationUseCases(this._repository);

  // ============================================================
  // 🔥 START REALTIME SYNC (Firebase → SQLite)
  // ============================================================

  Future<void> startListening() {
    return _repository.startListening();
  }

  // ============================================================
  // 🔥 REALTIME STREAMS (Expose to Service / ViewModel)
  // ============================================================

  Stream<LocalUser> get onAdded => _repository.onAdded;

  Stream<LocalUser> get onChanged => _repository.onChanged;

  Stream<String> get onRemoved => _repository.onRemoved;

  // ============================================================
  // 🔹 CLIENTS (Offline First)
  // ============================================================

  Future<Either<AppError, Unit>> addClient(LocalUser client) {
    return _repository.addClientDomain(client);
  }

  Future<Either<AppError, Unit>> updateClient(LocalUser client) {
    return _repository.updateClientDomain(client);
  }

  Future<Either<AppError, Unit>> deleteClient(String key) {
    return _repository.deleteClientDomain(key);
  }

  Future<Either<AppError, List<LocalUser>>> getClients(
      SQLiteQueryParams query,
      ) {
    return _repository.getClientsDomain(query);
  }

  // ============================================================
  // 🌐 CLIENTS (ONLINE ONLY)
  // ============================================================

  Future<Either<AppError, List<LocalUser>>> getClientsOnline(
      Map<String, dynamic> firebaseFilter,
      ) {
    return _repository.getClientsOnlineDomain(firebaseFilter);
  }

  // ============================================================
  // 🛑 STOP REALTIME SYNC
  // ============================================================

  Future<void> dispose() {
    return _repository.dispose();
  }
}