import '../../index/index_main.dart';

class LegacyQueueDataSourceRepoImpl extends LegacyQueueDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  LegacyQueueDataSourceRepoImpl(this._clientSourceRepo);

  // ------------------------------------------------------------
  // 🔥 PATH RESOLVER
  // ------------------------------------------------------------
  String _resolveQueuePath({
    required String date,
    required bool isPatient,
    required String? doctorUid,
    required bool isOpenCloseFeature,
  }) {
    final safeDate = date.replaceAll("/", "-").trim();

    final String uid;

    if (isPatient) {
      if (doctorUid == null || doctorUid.isEmpty) {
        throw Exception("doctorUid is required when isPatient = true");
      }
      uid = doctorUid;
    } else {
      uid = LocalUser().getUserData().doctorKey ?? "";
      if (uid.isEmpty) {
        throw Exception("Doctor key is missing");
      }
    }

    final featureNode = isOpenCloseFeature ? "open_close_days" : "legacy_queue";

    return "doctors/$uid/$featureNode/$safeDate";
  }

  bool _isOpenCloseFeature(Map<String, dynamic> data) {
    return data.containsKey('isClosed');
  }

  // ------------------------------------------------------------
  // 🔹 GET Legacy Queue
  // ------------------------------------------------------------
  @override
  Future<List<LegacyQueueModel?>> getLegacyQueueByDate(
    String date,
    Map<String, dynamic> data, {
    bool isPatient = false,
    String? doctorUid,
  }) async {
    try {
      final path = _resolveQueuePath(
        date: date,
        isPatient: isPatient,
        doctorUid: doctorUid,
        isOpenCloseFeature: false,
      );

      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/$path.json",
        params: data, // 🔥 Firebase filter map
      );

      return handleResponse<LegacyQueueModel>(
        response,
        (json) => LegacyQueueModel.fromJson(json),
      );
    } catch (e) {
      debugPrint("❌ getLegacyQueueByDate error: $e");
      return [];
    }
  }

  // ------------------------------------------------------------
  // 🔒 GET Open / Close Days
  // ------------------------------------------------------------
  @override
  Future<List<LegacyQueueModel?>> getOpenCloseDaysByDate(
    String date,
    Map<String, dynamic> data, { // ✅ FIXED
    bool isPatient = false,
    String? doctorUid,
  }) async {
    try {
      final path = _resolveQueuePath(
        date: date,
        isPatient: isPatient,
        doctorUid: doctorUid,
        isOpenCloseFeature: true,
      );

      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/$path.json",
        params: data, // ✅ now supports Firebase filter
      );

      return handleResponse<LegacyQueueModel>(
        response,
        (json) => LegacyQueueModel.fromJson(json),
      );
    } catch (e) {
      debugPrint("❌ getOpenCloseDaysByDate error: $e");
      return [];
    }
  }

  // ------------------------------------------------------------
  // ➕ ADD
  // ------------------------------------------------------------
  @override
  Future<SuccessModel> addLegacyQueue(
    String date,
    String key,
    Map<String, dynamic> data, {
    bool isPatient = false,
    String? doctorUid,
  }) async {
    final isOpenClose = _isOpenCloseFeature(data);

    final path = _resolveQueuePath(
      date: date,
      isPatient: isPatient,
      doctorUid: doctorUid,
      isOpenCloseFeature: isOpenClose,
    );

    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/$path/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }

  // ------------------------------------------------------------
  // ✏️ UPDATE
  // ------------------------------------------------------------
  @override
  Future<SuccessModel> updateLegacyQueue(
    String date,
    String key,
    Map<String, dynamic> data, {
    bool isPatient = false,
    String? doctorUid,
  }) async {
    final isOpenClose = _isOpenCloseFeature(data);

    final path = _resolveQueuePath(
      date: date,
      isPatient: isPatient,
      doctorUid: doctorUid,
      isOpenCloseFeature: isOpenClose,
    );

    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/$path/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }

  // ------------------------------------------------------------
  // 🗑 DELETE
  // ------------------------------------------------------------
  @override
  Future<SuccessModel> deleteLegacyQueue(
    String date,
    String key, {
    bool isPatient = false,
    String? doctorUid,
    bool isOpenCloseFeature = false,
  }) async {
    final path = _resolveQueuePath(
      date: date,
      isPatient: isPatient,
      doctorUid: doctorUid,
      isOpenCloseFeature: isOpenCloseFeature,
    );

    final response = await _clientSourceRepo.request(
      HttpMethod.DELETE,
      "/$path/$key.json",
    );

    return SuccessModel.fromJson(response ?? {"message": "تم الحذف بنجاح"});
  }
}
