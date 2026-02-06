import '../../index/index_main.dart';

class LegacyQueueDataSourceRepoImpl extends LegacyQueueDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  LegacyQueueDataSourceRepoImpl(this._clientSourceRepo);

  // ------------------------------------------------------------
  // 🔥 PATH RESOLVER (Legacy Queue / Open-Close Days)
  // ------------------------------------------------------------
  String _resolveQueuePath({
    required String date,
    required bool isPatient,
    required String? doctorUid,
    required bool isOpenCloseFeature,
  }) {
    final safeDate = date.replaceAll("/", "-").trim();

    final String basePath;
    if (isPatient) {
      if (doctorUid == null || doctorUid.isEmpty) {
        throw Exception("doctorUid is required when isPatient = true");
      }
      basePath = "doctors/$doctorUid";
    } else {
      final uid = LocalUser().getUserData().doctorKey ?? "";
      basePath = "doctors/$uid";
    }

    final featureNode =
    isOpenCloseFeature ? "open_close_days" : "legacy_queue";

    return "$basePath/$featureNode/$safeDate";
  }

  /// 🧠 نحدد الفيتشر من الداتا نفسها
  bool _isOpenCloseFeature(Map<String, dynamic> data) {
    return data.containsKey('isClosed') && data['isClosed'] != null;
  }

  // ------------------------------------------------------------
  // 🔹 GET (Legacy Queue)
  // ------------------------------------------------------------
  @override
  Future<List<LegacyQueueModel?>> getLegacyQueueByDate(
      String date,
      Map<String, dynamic> params, {
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
  // 🔒 GET (Open / Close Days)
  // ------------------------------------------------------------
  @override
  Future<List<LegacyQueueModel?>> getOpenCloseDaysByDate(
      String date, {
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
  // ➕ ADD (Legacy OR Open-Close)
  // ------------------------------------------------------------
  @override
  Future<SuccessModel> addLegacyQueue(
      String date,
      String key,
      Map<String, dynamic> data, {
        bool isPatient = false,
        String? doctorUid,
      }) async {
    final path = _resolveQueuePath(
      date: date,
      isPatient: isPatient,
      doctorUid: doctorUid,
      isOpenCloseFeature: _isOpenCloseFeature(data),
    );

    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/$path/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }

  // ------------------------------------------------------------
  // ✏️ UPDATE (Legacy OR Open-Close)
  // ------------------------------------------------------------
  @override
  Future<SuccessModel> updateLegacyQueue(
      String date,
      String key,
      Map<String, dynamic> data, {
        bool isPatient = false,
        String? doctorUid,
      }) async {
    final path = _resolveQueuePath(
      date: date,
      isPatient: isPatient,
      doctorUid: doctorUid,
      isOpenCloseFeature: _isOpenCloseFeature(data),
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
