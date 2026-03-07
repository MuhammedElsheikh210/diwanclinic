import '../../index/index_main.dart';

abstract class AuthenticationRemoteDataSource {
  // ============================================================
  // 🔹 CRUD (SERVER)
  // ============================================================

  Future<void> createClient(LocalUser model);

  Future<void> updateClient(LocalUser model);

  Future<void> deleteClient(String key);

  // ============================================================
  // 🌐 FETCH (ONLINE READ)
  // ============================================================

  /// Fetch clients from Firebase using filters
  /// Used for: First load / cache rebuild / force refresh
  Future<List<LocalUser>> fetchClients(Map<String, dynamic> filters);

  // ============================================================
  // 🎧 REALTIME CONTROL
  // ============================================================

  Future<void> startListening();

  Future<void> stopListening();

  // ============================================================
  // 🔥 REALTIME STREAMS
  // ============================================================

  Stream<LocalUser> get onAdded;

  Stream<LocalUser> get onChanged;

  Stream<String> get onRemoved;
}