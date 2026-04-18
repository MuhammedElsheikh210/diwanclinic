import '../../index/index_main.dart';

abstract class AuthenticationRemoteDataSource {
  // ============================================================
  // 🔹 CRUD (SERVER)
  // ============================================================

  Future<void> createClient(Map<String, dynamic> model);

  Future<void> updateClient(Map<String, dynamic> model);

  Future<void> deleteClient(String key);

  // ============================================================
  // 🌐 FETCH (ONLINE READ)
  // ============================================================

  /// Fetch clients from Firebase using filters
  /// Used for: First load / cache rebuild / force refresh
  Future<List<Map<String, dynamic>>> fetchClients(
      Map<String, dynamic> filters,
      );

  /// ✅ NEW: Fetch single client by UID (ONLINE ONLY)
  /// Used for: Login / critical reads (no cache)
  Future<Map<String, dynamic>?> fetchClientByUid(String uid);

  // ============================================================
  // 🎧 REALTIME CONTROL
  // ============================================================

  Future<void> startListening();

  Future<void> stopListening();

  // ============================================================
  // 🔥 REALTIME STREAMS
  // ============================================================

  Stream<Map<String, dynamic>> get onAdded;

  Stream<Map<String, dynamic>> get onChanged;

  Stream<String> get onRemoved;
}