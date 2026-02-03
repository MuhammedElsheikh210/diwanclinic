// ignore_for_file: avoid_renaming_method_parameters

import 'package:diwanclinic/Domain/UseCases/visit_use_cases.dart';

import '../../index/index_main.dart';

class VisitService {
  final VisitUseCases useCase = initController(() => VisitUseCases(Get.find()));

  /// ➕ Add Visit
  Future<void> addVisitData({
    required VisitModel visit,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.addVisit(visit);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// 🔄 Update Visit
  Future<void> updateVisitData({
    required VisitModel visit,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.updateVisit(visit);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// 🗑 Delete Visit
  Future<void> deleteVisitData({
    required String visitKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.deleteVisit(visitKey);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// 🔍 Get All Visits
  Future<void> getVisitsData({
    required Map<String, dynamic> data,
    required SQLiteQueryParams query,
    required FirebaseFilter firebaseFilter,
    bool? isFiltered,
    required Function(List<VisitModel?>) voidCallBack,
  }) async {
    final result = await useCase.getVisits(
      firebaseFilter.toJson(),
      query,
      isFiltered,
    );
    result.fold(
      (l) => Loader.showError("Something went wrong"),
      (r) => voidCallBack(r),
    );
  }
}
