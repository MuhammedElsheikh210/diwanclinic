// ignore_for_file: avoid_renaming_method_parameters
import 'package:intl/intl.dart';
import '../../index/index_main.dart';

class ReservationDataSourceRepoImpl extends ReservationDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;
  final BaseSQLiteDataSourceRepo<ReservationModel> _sqliteRepo;

  ReservationDataSourceRepoImpl(this._clientSourceRepo)
    : _sqliteRepo = BaseSQLiteDataSourceRepo<ReservationModel>(
        tableName: "reservations",
        fromJson: (json) => ReservationModel.fromJson(json),
        toJson: (model) => model.toJson(),
        getId: (model) => model.key,
      );

  // ------------------------------------------------------------
  // 🔥 PATH RESOLVER (Doctor / Assistant / Patient)
  // ------------------------------------------------------------
  String _resolveReservationsPath({
    required String date,
    required bool isPatient,
    required String? doctorUid,
  }) {
    final safeDate = date.replaceAll("/", "-").trim();

    if (isPatient) {
      if (doctorUid == null || doctorUid.isEmpty) {
        throw Exception("doctorUid is required when isPatient = true");
      }

      return "doctors/$doctorUid/reservations/$safeDate";
    }

    // Doctor / Assistant (uses logged-in uid internally)
    return ApiConstatns.reservationsByDate(date);
  }

  // ------------------------------------------------------------
  // 🔹 FETCH ONLINE
  // ------------------------------------------------------------
  Future<List<ReservationModel?>> _fetchOnline(
    String date,
    Map<String, dynamic> params, {
    required bool isPatient,
    required String? doctorUid,
  }) async {
    final path = _resolveReservationsPath(
      date: date,
      isPatient: isPatient,
      doctorUid: doctorUid,
    );

    final response = await _clientSourceRepo.request(
      HttpMethod.GET,
      "/$path.json",
      params: params,
    );

    final list = handleResponse<ReservationModel>(
      response,
      (json) => ReservationModel.fromJson(json),
    );

    await _saveListLocally(list);
    return list;
  }

  Future<void> _saveListLocally(List<ReservationModel?> list) async {
    for (final r in list) {
      if (r?.key != null) {
        await _sqliteRepo.addItem(r!);
      }
    }
  }

  // ------------------------------------------------------------
  // 🔹 GET RESERVATIONS
  // ------------------------------------------------------------
  @override
  Future<List<ReservationModel?>> getReservations(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? fromOnline,
    bool? isFiltered,
    String date, {
    bool isPatient = false,
    String? doctorUid,
  }) async {
    try {
      if (fromOnline == true) {
        return await _fetchOnline(
          date,
          data,
          isPatient: isPatient,
          doctorUid: doctorUid,
        );
      }

      final local = await _sqliteRepo.getAll(query: query);

      if (isFiltered == false) return local;
      if (local.isNotEmpty) return local;

      return await _fetchOnline(
        date,
        data,
        isPatient: isPatient,
        doctorUid: doctorUid,
      );
    } catch (_) {
      return [];
    }
  }

  // ------------------------------------------------------------
  // 🔹 ADD RESERVATION
  // ------------------------------------------------------------
  @override
  Future<SuccessModel> addReservation(
    Map<String, dynamic> data,
    String key,
    String date, {
    bool localOnly = false,
    bool isPatient = false,
    String? doctorUid,
  }) async {
    try {
      final model = ReservationModel.fromJson(data);
      await _sqliteRepo.addItem(model);

      if (localOnly) {
        return SuccessModel(message: "Local only");
      }

      final path = _resolveReservationsPath(
        date: date,
        isPatient: isPatient,
        doctorUid: doctorUid,
      );

      final res = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/$path/$key.json",
        params: data,
      );

      return SuccessModel.fromJson(res);
    } catch (_) {
      return SuccessModel(message: "Error adding");
    }
  }

  // ------------------------------------------------------------
  // 🔹 UPDATE RESERVATION
  // ------------------------------------------------------------
  @override
  Future<SuccessModel> updateReservation(
    Map<String, dynamic> data,
    String key,
    String date, {
    bool localOnly = false,
    bool isPatient = false,
    String? doctorUid,
  }) async {
    try {
      final model = ReservationModel.fromJson(data);
      await _sqliteRepo.updateItem(model);

      if (localOnly) {
        return SuccessModel(message: "Local only");
      }

      final path = _resolveReservationsPath(
        date: date,
        isPatient: isPatient,
        doctorUid: doctorUid,
      );

      final res = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/$path/$key.json",
        params: data,
      );

      return SuccessModel.fromJson(res);
    } catch (_) {
      return SuccessModel(message: "Error updating");
    }
  }

  // ------------------------------------------------------------
  // 🔹 DELETE RESERVATION
  // ------------------------------------------------------------
  @override
  Future<SuccessModel> deleteReservation(
    Map<String, dynamic> data,
    String key,
    String date, {
    bool isPatient = false,
    String? doctorUid,
  }) async {
    try {
      await _sqliteRepo.deleteItem(key);

      final path = _resolveReservationsPath(
        date: date,
        isPatient: isPatient,
        doctorUid: doctorUid,
      );

      final res = await _clientSourceRepo.request(
        HttpMethod.DELETE,
        "/$path/$key.json",
        params: data,
      );

      return res == null
          ? SuccessModel(message: "Deleted")
          : SuccessModel.fromJson(res);
    } catch (_) {
      return SuccessModel(message: "Error deleting");
    }
  }

  // ------------------------------------------------------------
  // 🔹 PATIENT META (ONLINE ONLY)
  // ------------------------------------------------------------
  @override
  Future<SuccessModel> updatePatientReservation(
    ReservationModel meta,
    String key,
  ) async {
    try {
      final uid = meta.patientUid;
      final path = "patients/$uid/reservationsMeta";

      final res = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/$path/$key.json",
        params: meta.toJson(),
      );

      return SuccessModel.fromJson(res);
    } catch (e) {
      debugPrint("Error updatePatientReservation: $e");
      return SuccessModel(message: "Error updating patient reservation meta");
    }
  }

  @override
  Future<List<ReservationModel>> getPatientReservationsMeta(
    String patientKey,
  ) async {
    try {
      final uid = LocalUser().getUserData().uid ?? "";
      final path = "patients/$uid/reservationsMeta";

      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/$path.json",
        params: {},
      );

      if (response == null) return [];

      if (response is Map<String, dynamic>) {
        final List<ReservationModel> result = [];

        response.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            final map = Map<String, dynamic>.from(value);
            map['key'] ??= key;
            result.add(ReservationModel.fromJson(map));
          }
        });

        return result;
      }

      return [];
    } catch (e) {
      debugPrint("Error getPatientReservationsMeta: $e");
      return [];
    }
  }

  @override
  Future<SuccessModel> addPatientReservationMeta(
    ReservationModel meta,
    String patientKey,
  ) async {
    try {
      final uid = meta.patientUid;
      final key = meta.key;
      final path = "patients/$uid/reservationsMeta";

      final res = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/$path/$key.json",
        params: meta.toJson(),
      );

      return SuccessModel.fromJson(res);
    } catch (e) {
      debugPrint("Error addPatientReservationMeta: $e");
      return SuccessModel(message: "Error adding patient reservation meta");
    }
  }
}
