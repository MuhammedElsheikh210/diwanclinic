import '../../index/index_main.dart';

class AuthenticationRemoteDataSourceImpl extends AuthenticationDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;
  final BaseSQLiteDataSourceRepo<LocalUser> _sqliteRepo;

  AuthenticationRemoteDataSourceImpl(this._clientSourceRepo)
    : _sqliteRepo = BaseSQLiteDataSourceRepo<LocalUser>(
        tableName: "clients",
        fromJson: (json) => LocalUser.fromJson(json),
        toJson: (model) => model.toJson(),
        getId: (model) => model.key,
      );

  // ─────────────────────────────────────────────
  // 🧭 Helper for logging
  void _trace(String msg) {
  }

  // ─────────────────────────────────────────────
  // 🔹 Fetch all clients (API only)
  @override
  Future<List<LocalUser?>> getClients(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      // 🔹 Fetch directly from API
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.clients}.json",
        params: data,
      );

      // ✅ Use generic handler to safely parse Firebase data
      List<LocalUser?> clientList = handleResponse<LocalUser>(
        response,
        (json) => LocalUser.fromJson(json),
      );

      //  🔸 Local cache disabled (like getClinics)
      for (final client in clientList) {
        if (client?.key?.isNotEmpty == true) {
          await _sqliteRepo.addItem(client!);
        }
      }
      return clientList;
    } catch (e) {
      _trace("❌ Error fetching clients from API: $e");
      return [];
    }
  }

  @override
  Future<List<LocalUser?>> getClients_local(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      // 🔸 Local disabled:
      final sqliteData = await _sqliteRepo.getAll(query: query);

      return sqliteData;
    } catch (e) {
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // 🔹 Get one client by filter
  @override
  Future<LocalUser?> getClient_Individual(Map<String, dynamic> data) async {
    try {
      _trace("🔍 Fetching single client from API...");
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.clients}.json",
        params: data,
      );

      if (response == null || response.isEmpty) {
        _trace("⚠️ No client found for given query.");
        return null;
      }

      final userJson = response.values.first as Map<String, dynamic>;
      _trace("📦 User JSON: $userJson");

      final user = LocalUser.fromJson(userJson);

      if (user.key?.isNotEmpty == true) {
        try {
          await _sqliteRepo.updateItem(user);
          _trace("🧱 Updated client locally: ${user.key}");
        } catch (e) {
          _trace("⚠️ Failed to update local client: $e");
        }
      }

      return user;
    } catch (e) {
      _trace("❌ Error fetching individual client: $e");
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // 🔹 Add new client
  @override
  Future<SuccessModel> addClient(Map<String, dynamic> data, String key) async {
    final client = LocalUser.fromJson(data);
    _trace("➕ Adding new client: ${client.toJson()}");

    try {
      await _sqliteRepo.addItem(client);
      _trace("🧱 Added to local DB: ${client.key}");
    } catch (e) {
      _trace("⚠️ Failed to add local client: $e");
    }

    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.clients}/$key.json",
      params: data,
    );

    _trace("🌍 API add response: $response");

    return SuccessModel.fromJson(response);
  }

  // ─────────────────────────────────────────────
  // 🔹 Update existing client
  @override
  Future<SuccessModel> updateClient(
    Map<String, dynamic> data,
    String key,
  ) async {
    final client = LocalUser.fromJson(data);
    _trace("🔄 Updating client: ${client.key}");

    try {
      await _sqliteRepo.updateItem(client);
      _trace("🧱 Updated in local DB: ${client.key}");
    } catch (e) {
      _trace("⚠️ Failed to update local client: $e");
    }

    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.clients}/$key.json",
      params: data,
    );

    _trace("🌍 API update response: $response");

    return SuccessModel.fromJson(response);
  }

  // ─────────────────────────────────────────────
  // 🔹 Delete client
  @override
  Future<SuccessModel> deleteClient(
    Map<String, dynamic> data,
    String key,
  ) async {
    _trace("🗑 Deleting client: $key");

    try {
      await _sqliteRepo.deleteItem(key);
      _trace("🧱 Deleted from local DB: $key");
    } catch (e) {
      _trace("⚠️ Failed to delete from local DB: $e");
    }

    final response = await _clientSourceRepo.request(
      HttpMethod.DELETE,
      "/${ApiConstatns.clients}/$key.json",
      params: data,
    );

    _trace("🌍 API delete response: $response");

    return response == null
        ? SuccessModel(message: Strings.delete_message.tr)
        : SuccessModel.fromJson(response);
  }

  // ─────────────────────────────────────────────
  // 🔹 NEW: update sync timestamps
  @override
  Future<SuccessModel> updateSyncStatus(
    SyncStatusModel model,
    SyncStatus syncStatus,
  ) async {
    try {
      _trace("🕒 Updating sync status for key: ${model.key}");
      String path = "";
      if (syncStatus == SyncStatus.client) {
        path = "/sync_status/${model.key}.json";
      } else {
        path = "/${ApiConstatns.syncNodel}${model.key}.json";
      }

      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        path,
        params: model.toJson(),
      );

      _trace("🌍 Sync status update response: $response");

      return SuccessModel.fromJson(response);
    } catch (e) {
      _trace("❌ Error updating sync status: $e");
      return SuccessModel(message: "Failed");
    }
  }

  // ─────────────────────────────────────────────
  // 🔹 NEW: Get sync status by key
  @override
  Future<SyncStatusModel?> getSyncStatus(
    String key,
    SyncStatus syncStatus,
  ) async {
    try {
      _trace("🔍 Fetching sync status for key: $key");
      String path = "";
      if (syncStatus == SyncStatus.client) {
        path = "/sync_status/${key}.json";
      } else {
        path = "/${ApiConstatns.syncNodel}${key}.json";
      }
      final response = await _clientSourceRepo.request(HttpMethod.GET, path);

      if (response == null) {
        _trace("⚠️ No sync status found for key: $key");
        return null;
      }

      final json = Map<String, dynamic>.from(response);
      json['key'] = key;

      final result = SyncStatusModel.fromJson(json);

      _trace("✅ Sync status loaded: ${result.toJson()}");

      return result;
    } catch (e) {
      _trace("❌ Error fetching sync status: $e");
      return null;
    }
  }
}
