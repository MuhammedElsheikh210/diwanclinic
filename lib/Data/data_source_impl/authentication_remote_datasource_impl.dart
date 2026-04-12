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

  final _addedController =
  StreamController<Map<String, dynamic>>.broadcast();

  final _changedController =
  StreamController<Map<String, dynamic>>.broadcast();

  final _removedController = StreamController<String>.broadcast();

  @override
  Stream<Map<String, dynamic>> get onAdded => _addedController.stream;

  @override
  Stream<Map<String, dynamic>> get onChanged => _changedController.stream;

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
      final json = _parse(event.snapshot);
      if (json != null) {
        print("➕ Client Added → ${json['uid']}");
        _addedController.add(json);
      }
    });

    final changedSub = _rootRef!.onChildChanged.listen((event) {
      final json = _parse(event.snapshot);
      if (json != null) {
        print("🔄 Client Updated → ${json['uid']}");
        _changedController.add(json);
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
  // 🌐 FETCH CLIENTS
  // ============================================================

  @override
  Future<List<Map<String, dynamic>>> fetchClients(
      Map<String, dynamic> filters) async {
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

      final List<Map<String, dynamic>> users = [];

      response.forEach((key, value) {
        if (value is Map) {
          final json = Map<String, dynamic>.from(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );

          json['uid'] = key; // 🔥 مهم جدًا
          users.add(json);
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
  // 🧠 PARSE SNAPSHOT
  // ============================================================

  Map<String, dynamic>? _parse(DataSnapshot snapshot) {
    final data = snapshot.value;

    if (data == null || data is! Map) return null;

    try {
      final json = Map<String, dynamic>.from(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );

      json['uid'] = snapshot.key;

      return json;
    } catch (e) {
      print("🔥 Client parse error → $e");
      return null;
    }
  }

  // ============================================================
  // ☁️ CREATE
  // ============================================================

  @override
  Future<void> createClient(Map<String, dynamic> user) async {
    final key = user['uid'];
    if (key == null) return;

    print("☁️ Create Client → $key");

    await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.clients}/$key.json",
      params: user,
    );
  }

  // ============================================================
  // 🔄 UPDATE
  // ============================================================

  @override
  Future<void> updateClient(Map<String, dynamic> user) async {
    final key = user['uid'];
    if (key == null) return;

    print("☁️ Update Client → $key");

    await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.clients}/$key.json",
      params: user,
    );
  }

  // ============================================================
  // ❌ DELETE
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