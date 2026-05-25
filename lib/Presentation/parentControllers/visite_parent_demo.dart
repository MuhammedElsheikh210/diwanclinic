import '../../index/index_main.dart';

class VisitParentService {
  final BaseService<VisitModel> service = Get.find<BaseService<VisitModel>>(
    tag: "visits",
  );

  /// =========================
  /// ADD
  /// =========================
  Future<void> addVisit({
    required VisitModel visit,
    required Function(ResponseStatus) callBack,
  }) async {
    await service.addData(
      item: visit,
      toJson: (item) => item.toJson(),
      id: visit.key ?? "",
      voidCallBack: callBack,
    );
  }

  /// =========================
  /// UPDATE
  /// =========================
  Future<void> updateVisit({
    required VisitModel visit,
    required Function(ResponseStatus) callBack,
  }) async {
    await service.updateData(
      item: visit,
      toJson: (item) => item.toJson(),
      id: visit.key ?? "",
      voidCallBack: callBack,
    );
  }

  /// =========================
  /// DELETE
  /// =========================
  Future<void> deleteVisit({
    required String id,
    required Function(ResponseStatus) callBack,
  }) async {
    await service.deleteData(id: id, voidCallBack: callBack);
  }

  /// =========================
  /// GET ALL
  /// =========================
  Future<void> getVisits({
    required Map<String, dynamic> data,
    required Function(List<VisitModel?>) callBack,
  }) async {
    await service.getData(data: data, voidCallBack: callBack);
  }
}
