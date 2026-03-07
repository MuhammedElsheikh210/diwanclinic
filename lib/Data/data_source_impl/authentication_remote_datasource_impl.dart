import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';

class AuthenticationRemoteDataSourceImpl
    implements AuthenticationRemoteDataSource {
  final FirebaseDatabase _database;
  final ClientSourceRepo _clientSourceRepo;

  AuthenticationRemoteDataSourceImpl(this._database, this._clientSourceRepo);

  DatabaseReference? _rootRef;
  final List<StreamSubscription> _subscriptions = [];

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
  // 🎧 START LISTENING
  // ============================================================

  @override
  Future<void> startListening() async {
    await stopListening();

    const path = "clients";
    _rootRef = _database.ref(path);

    print("🎧 Listening on → $path");

    final addedSub = _rootRef!.onChildAdded.listen((event) {
      final model = _parseUser(event.snapshot);
      if (model != null) {
        print("➕ Client Added → ${model.key}");
        _addedController.add(model);
      }
    });

    final changedSub = _rootRef!.onChildChanged.listen((event) {
      final model = _parseUser(event.snapshot);
      if (model != null) {
        print("🔄 Client Updated → ${model.key}");
        _changedController.add(model);
      }
    });

    final removedSub = _rootRef!.onChildRemoved.listen((event) {
      final key = event.snapshot.key;
      if (key != null) {
        print("❌ Client Removed → $key");
        _removedController.add(key);
      }
    });

    _subscriptions.addAll([addedSub, changedSub, removedSub]);
  }


  // ============================================================
// 🌐 FETCH CLIENTS (ONLINE READ)
// ============================================================

  @override
  Future<List<LocalUser>> fetchClients(Map<String, dynamic> filters) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.clients}.json",
        params: filters,
      );

      if (response == null || response is! Map) {
        print("⚠️ No clients found");
        return [];
      }

      final List<LocalUser> users = [];

      response.forEach((key, value) {
        if (value is Map) {
          final json = Map<String, dynamic>.from(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );
          json['key'] = key;
          users.add(LocalUser.fromJson(json));
        }
      });

      print("☁️ Clients fetched → ${users.length}");
      return users;
    } catch (e) {
      print("🔥 Fetch Clients Error → $e");
      return [];
    }
  }

  // ============================================================
  // 🧠 PARSE USER
  // ============================================================

  LocalUser? _parseUser(DataSnapshot snapshot) {
    final data = snapshot.value;

    if (data == null || data is! Map) return null;

    try {
      final json = Map<String, dynamic>.from(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );

      json['key'] = snapshot.key;

      return LocalUser.fromJson(json);
    } catch (e) {
      print("🔥 Client parse error → $e");
      return null;
    }
  }

  // ============================================================
  // ☁️ CREATE CLIENT
  // ============================================================

  @override
  Future<void> createClient(LocalUser user) async {
    final key = user.key;
    print("☁️ Create Client → $key");

    await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.clients}/$key.json",
      params: user.toJson(),
    );
  }

  // ============================================================
  // 🔄 UPDATE CLIENT
  // ============================================================

  @override
  Future<void> updateClient(LocalUser user) async {
    final key = user.key;
    print("☁️ Update Client → $key");

    await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.clients}/$key.json",
      params: user.toJson(),
    );
  }

  // ============================================================
  // ❌ DELETE CLIENT
  // ============================================================

  @override
  Future<void> deleteClient(String key) async {
    print("☁️ Delete Client → $key");

    await _clientSourceRepo.request(
      HttpMethod.DELETE,
      "/${ApiConstatns.clients}/$key.json",
      params: {},
    );
  }

  // ============================================================
  // 🛑 STOP LISTENING
  // ============================================================

  @override
  Future<void> stopListening() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    _rootRef = null;

    print("🛑 Client listeners stopped");
  }
}
