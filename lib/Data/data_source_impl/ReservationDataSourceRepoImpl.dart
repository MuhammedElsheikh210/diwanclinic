// ignore_for_file: avoid_renaming_method_parameters
import '../../index/index_main.dart';

class ReservationDataSourceRepoImpl extends ReservationDataSourceRepo {
  final BaseSQLiteDataSourceRepo<ReservationModel> _sqliteRepo;
  final ClientSourceRepo _clientSourceRepo;

  ReservationDataSourceRepoImpl(this._clientSourceRepo)
    : _sqliteRepo = BaseSQLiteDataSourceRepo<ReservationModel>(
        tableName: "reservations",
        fromJson: (json) => ReservationModel.fromJson(json),
        toJson: (model) => model.toJson(),
        getId: (model) => model.key,
      );

  // ============================================================
  // 🔹 LOCAL RESERVATIONS (Offline First)
  // ============================================================

  @override
  Future<List<ReservationModel?>> getReservations(
    SQLiteQueryParams query,
  ) async {
    final finalQuery = SQLiteQueryParams(
      where:
          query.where != null
              ? "(${query.where}) AND is_deleted = 0"
              : "is_deleted = 0",
      whereArgs: query.whereArgs,
      orderBy: query.orderBy,
      limit: query.limit,
      offset: query.offset,
      groupBy: query.groupBy,
      having: query.having,
      distinct: query.distinct,
    );

    return await _sqliteRepo.getAll(query: finalQuery);
  }

  @override
  Future<void> addReservation(ReservationModel model) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final newModel = model.copyWith(
      updatedAt: now,
      serverUpdatedAt: 0,
      isDeleted: false,
    );

    await _sqliteRepo.addItem(newModel);
  }

  @override
  Future<void> updateReservation(ReservationModel model) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final updated = model.copyWith(
      updatedAt: now,
    );

    await _sqliteRepo.updateItem(updated);
  }

  @override
  Future<void> deleteReservation(String key) async {
    final existing = await _sqliteRepo.getItem(key);
    if (existing == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    final deleted = existing.copyWith(
      isDeleted: true,
      updatedAt: now,
    );

    await _sqliteRepo.updateItem(deleted);
  }




  @override
  Future<List<ReservationModel>> getPendingReservations() async {
    final list = await _sqliteRepo.getAll(
      query: SQLiteQueryParams(
        where: "sync_status != ?",
        whereArgs: ['synced'],
      ),
    );

    return list.whereType<ReservationModel>().toList();
  }


  @override
  Future<SuccessModel> addPatientReservationMeta(
    ReservationModel meta,
    String patientKey,
  ) async {
    final uid = meta.patientUid;
    final key = meta.key;
    final path = "patients/$uid/reservationsMeta";

    final res = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/$path/$key.json",
      params: meta.toJson(),
    );

    return SuccessModel.fromJson(res);
  }

  @override
  Future<SuccessModel> updatePatientReservation(
    ReservationModel meta,
    String key,
  ) async {
    final uid = meta.patientUid;
    final path = "patients/$uid/reservationsMeta";

    final res = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/$path/$key.json",
      params: meta.toJson(),
    );

    return SuccessModel.fromJson(res);
  }

  @override
  Future<List<ReservationModel>> getPatientReservationsMeta(
      String? patientKey,
      ) async {
    // ============================================================
    // 🧠 RESOLVE UID
    // ============================================================

    final sessionUser = Get.find<UserSession>().user?.user;

    final uid = patientKey ?? sessionUser?.uid;

    if (uid == null || uid.isEmpty) {
      throw Exception("❌ Patient UID is missing");
    }

    final path = "patients/$uid/reservationsMeta";

    // ============================================================
    // 🌐 API CALL
    // ============================================================

    final response = await _clientSourceRepo.request(
      HttpMethod.GET,
      "/$path.json",
      params: {},
    );

    if (response == null) return [];

    final List<ReservationModel> result = [];

    // ============================================================
    // 🧩 PARSE RESPONSE
    // ============================================================

    if (response is Map<String, dynamic>) {
      response.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final map = Map<String, dynamic>.from(value);
          map['key'] ??= key;

          result.add(ReservationModel.fromJson(map));
        }
      });
    }

    return result;
  }



  @override
  Future<void> upsertFromServer(ReservationModel serverModel) async {
    if (serverModel.key == null) return;

    final local = await _sqliteRepo.getItem(serverModel.key!);

    final serverTime =
        serverModel.serverUpdatedAt ?? DateTime.now().millisecondsSinceEpoch;

    if (local == null) {
      await _sqliteRepo.addItem(
        serverModel.copyWith(
          serverUpdatedAt: serverTime,
          updatedAt: serverTime,
        ),
      );
      return;
    }

    if (serverTime >= (local.serverUpdatedAt ?? 0)) {
      await _sqliteRepo.updateItem(
        serverModel.copyWith(
          serverUpdatedAt: serverTime,
          updatedAt: serverTime,
        ),
      );
    }
  }

  @override
  Future<void> markAsSynced(String key, {int? serverUpdatedAt}) async {
    final local = await _sqliteRepo.getItem(key);
    if (local == null) return;

    final serverTime = serverUpdatedAt ?? DateTime.now().millisecondsSinceEpoch;

    await _sqliteRepo.updateItem(
      local.copyWith(
        serverUpdatedAt: serverTime,
      ),
    );
  }
}
