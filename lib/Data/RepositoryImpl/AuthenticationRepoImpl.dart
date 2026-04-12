import 'dart:async';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final AuthenticationDataSourceRepo _local;
  final AuthenticationRemoteDataSource _remote;
  final ConnectivityService _connectivity;

  AuthenticationRepositoryImpl(this._local, this._remote, this._connectivity);

  final Set<String> _processedKeys = {};

  StreamSubscription? _addedSub;
  StreamSubscription? _changedSub;
  StreamSubscription? _removedSub;

  // ============================================================
  // 🌊 STREAM CONTROLLERS
  // ============================================================

  final _addedController = StreamController<LocalUser>.broadcast();
  final _changedController = StreamController<LocalUser>.broadcast();
  final _removedController = StreamController<String>.broadcast();

  @override
  Stream<LocalUser> get onAdded => _addedController.stream;

  @override
  Stream<LocalUser> get onChanged => _changedController.stream;

  @override
  Stream<String> get onRemoved => _removedController.stream;

  // ============================================================
  // 🎧 REALTIME SYNC
  // ============================================================

  @override
  Future<void> startListening() async {
    log("🎧 Start Listening Clients");

    _processedKeys.clear();
    await _remote.startListening();

    _addedSub?.cancel();
    _changedSub?.cancel();
    _removedSub?.cancel();

    _addedSub = _remote.onAdded.listen((json) async {
      final uid = json['uid'];
      if (uid == null) return;

      if (_processedKeys.contains(uid)) return;
      _processedKeys.add(uid);

      final model = LocalUser.fromMap(json);

      log("🔥 Client Added → $uid");

      await _local.upsertFromServer(model);
      _addedController.add(model);
    });

    _changedSub = _remote.onChanged.listen((json) async {
      final uid = json['uid'];
      if (uid == null) return;

      final model = LocalUser.fromMap(json);

      log("🔄 Client Updated → $uid");

      await _local.upsertFromServer(model);
      _changedController.add(model);
    });

    _removedSub = _remote.onRemoved.listen((key) async {
      log("❌ Client Removed → $key");

      await _local.deleteClient(key);
      _removedController.add(key);
    });
  }

  // ============================================================
  // 🛑 STOP
  // ============================================================

  @override
  Future<void> dispose() async {
    _processedKeys.clear();

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    await _remote.stopListening();

    if (!_addedController.isClosed) await _addedController.close();
    if (!_changedController.isClosed) await _changedController.close();
    if (!_removedController.isClosed) await _removedController.close();
  }

  // ============================================================
  // 📦 LOCAL
  // ============================================================

  @override
  Future<Either<AppError, List<LocalUser>>> getClientsDomain(
    SQLiteQueryParams query,
  ) async {
    try {
      final result = await _local.getClients(query);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // 🌐 ONLINE
  // ============================================================

  @override
  Future<Either<AppError, List<LocalUser>>> getClientsOnlineDomain(
    Map<String, dynamic> firebaseFilter,
  ) async {
    try {
      if (!await _connectivity.isOnline()) {
        return Left(AppError("No internet connection"));
      }

      final remoteList = await _remote.fetchClients(firebaseFilter);

      final users = remoteList.map((e) => LocalUser.fromMap(e)).toList();

      for (final user in users) {
        await _local.upsertFromServer(user);
      }

      return Right(users);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // ➕ ADD
  // ============================================================

  @override
  Future<Either<AppError, Unit>> addClientDomain(LocalUser model) async {
    try {
      await _local.addClient(model);

      if (await _connectivity.isOnline()) {
        await _remote.createClient(model.toJson());
      }

      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // 🔄 UPDATE
  // ============================================================

  @override
  Future<Either<AppError, Unit>> updateClientDomain(LocalUser model) async {
    try {
      await _local.updateClient(model);

      if (await _connectivity.isOnline()) {
        await _remote.updateClient(model.toJson());
      }

      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // ❌ DELETE
  // ============================================================

  @override
  Future<Either<AppError, Unit>> deleteClientDomain(String key) async {
    try {
      await _local.deleteClient(key);

      if (await _connectivity.isOnline()) {
        await _remote.deleteClient(key);
      }

      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
