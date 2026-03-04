import '../../index/index_main.dart';

abstract class AuthenticationDataSourceRepo {
  // 🔹 Get all clients or filtered list
  Future<List<LocalUser?>> getClients(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );

  Future<List<LocalUser?>> getClients_local(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );

  // 🔹 Get single client (by UID or filter)
  Future<LocalUser?> getClient_Individual(Map<String, dynamic> data);

  // 🔹 Add new client
  Future<SuccessModel> addClient(Map<String, dynamic> data, String key);

  // 🔹 Delete client
  Future<SuccessModel> deleteClient(Map<String, dynamic> data, String key);

  // 🔹 Update client
  Future<SuccessModel> updateClient(Map<String, dynamic> data, String key);


}

enum SyncStatusAuth {
  client, // waiting to sync
  reservation, // currently syncing
  // sync failed
}
