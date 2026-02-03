import '../../index/index_main.dart';

class LegacyQueueDataSourceRepoImpl extends LegacyQueueDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  LegacyQueueDataSourceRepoImpl(this._clientSourceRepo);

  // ------------------------------------------------------------
  // 🔥 PATH RESOLVER (Doctor / Assistant / Patient)
  // ------------------------------------------------------------
  String _resolveLegacyQueuePath({
    required String date,
    required bool isPatient,
    required String? doctorUid,
  }) {
    final safeDate = date.replaceAll("/", "-").trim();

    if (isPatient) {
      if (doctorUid == null || doctorUid.isEmpty) {
        throw Exception("doctorUid is required when isPatient = true");
      }
      return "doctors/$doctorUid/legacy_queue/$safeDate";
    }

    // Doctor / Assistant
    String uid = LocalUser().getUserData().doctorKey ?? "";
    return "doctors/$uid/legacy_queue/$safeDate";
  }

  // ------------------------------------------------------------
  // 🔹 GET
  // ------------------------------------------------------------
  @override
  Future<List<LegacyQueueModel?>> getLegacyQueueByDate(
    String date,
    Map<String, dynamic> params, {
    bool isPatient = false,
    String? doctorUid,
  }) async {
    try {
      final path = _resolveLegacyQueuePath(
        date: date,
        isPatient: isPatient,
        doctorUid: doctorUid,
      );

      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/$path.json",
        params: params,
      );

      return handleResponse<LegacyQueueModel>(
        response,
        (json) => LegacyQueueModel.fromJson(json),
      );
    } catch (_) {
      return [];
    }
  }

  // ------------------------------------------------------------
  // 🔹 ADD
  // ------------------------------------------------------------
  @override
  Future<SuccessModel> addLegacyQueue(
    String date,
    String key,
    Map<String, dynamic> data, {
    bool isPatient = false,
    String? doctorUid,
  }) async {
    final path = _resolveLegacyQueuePath(
      date: date,
      isPatient: isPatient,
      doctorUid: doctorUid,
    );

    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/$path/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }

  // ------------------------------------------------------------
  // 🔹 UPDATE
  // ------------------------------------------------------------
  @override
  Future<SuccessModel> updateLegacyQueue(
    String date,
    String key,
    Map<String, dynamic> data, {
    bool isPatient = false,
    String? doctorUid,
  }) async {
    final path = _resolveLegacyQueuePath(
      date: date,
      isPatient: isPatient,
      doctorUid: doctorUid,
    );

    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/$path/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }

  // ------------------------------------------------------------
  // 🔹 DELETE
  // ------------------------------------------------------------
  @override
  Future<SuccessModel> deleteLegacyQueue(
    String date,
    String key, {
    bool isPatient = false,
    String? doctorUid,
  }) async {
    final path = _resolveLegacyQueuePath(
      date: date,
      isPatient: isPatient,
      doctorUid: doctorUid,
    );

    final response = await _clientSourceRepo.request(
      HttpMethod.DELETE,
      "/$path/$key.json",
    );

    return SuccessModel.fromJson(response ?? {"message": "تم الحذف بنجاح"});
  }
}
