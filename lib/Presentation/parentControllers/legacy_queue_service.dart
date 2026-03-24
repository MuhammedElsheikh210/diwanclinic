// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class LegacyQueueService {
  final LegacyQueueUseCases useCase = initController(
    () => LegacyQueueUseCases(Get.find()),
  );

  // ------------------------------------------------------------
  // 🔥 DOCTOR RESOLVER (مهم جدًا)
  // ------------------------------------------------------------
  String? _resolveDoctorUid(String? doctorUid) {
    if (doctorUid != null && doctorUid.isNotEmpty) return doctorUid;

    return LocalUser().getUserData().doctorKey;
  }

  // ------------------------------------------------------------
  // 🧾 Legacy Queue
  // ------------------------------------------------------------

  Future<void> addLegacyQueueData({
    required LegacyQueueModel model,
    required Function(ResponseStatus) voidCallBack,
    bool isPatient = false,
    String? doctorUid,
  }) async {
    Loader.show();

    final result = await useCase.addLegacyQueue(
      model,
      isPatient: isPatient,
      doctorUid: _resolveDoctorUid(doctorUid),
    );

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> updateLegacyQueueData({
    required LegacyQueueModel model,
    required Function(ResponseStatus) voidCallBack,
    bool isPatient = false,
    String? doctorUid,
  }) async {
    Loader.show();

    final result = await useCase.updateLegacyQueue(
      model,
      isPatient: isPatient,
      doctorUid: _resolveDoctorUid(doctorUid),
    );

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> deleteLegacyQueueData({
    required String date,
    required String key,
    required Function(ResponseStatus) voidCallBack,
    bool isPatient = false,
    String? doctorUid,
    bool? isOpenClosed,
  }) async {
    Loader.show();

    final result = await useCase.deleteLegacyQueue(
      date,
      key,
      isPatient: isPatient,
      doctorUid: _resolveDoctorUid(doctorUid),
      isOpenClosed: isOpenClosed,
    );

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> getLegacyQueueByDateData({
    required FirebaseFilter firebaseFilter,
    required Function(List<LegacyQueueModel?>) voidCallBack,
    bool isPatient = false,
    String? doctorUid,
  }) async {
    final result = await useCase.getLegacyQueueByDate(
      firebaseFilter.toJson() ?? {},
      isPatient: isPatient,
      doctorUid: _resolveDoctorUid(doctorUid),
    );

    result.fold(
      (l) => Loader.showError("Something went wrong"),
      (r) => voidCallBack(r),
    );
  }

  // ------------------------------------------------------------
  // 🔒 Open / Close Days
  // ------------------------------------------------------------

  Future<void> getOpenCloseDaysByDateData({
    required String date,
    required FirebaseFilter firebaseFilter,
    required Function(List<LegacyQueueModel?>) voidCallBack,
    bool isPatient = false,
    String? doctorUid,
  }) async {
    final result = await useCase.getOpenCloseDaysByDate(
      date,
      firebaseFilter.toJson() ?? {},
      isPatient: isPatient,
      doctorUid: _resolveDoctorUid(doctorUid),
    );

    result.fold(
      (l) => Loader.showError("Something went wrong"),
      (r) => voidCallBack(r),
    );
  }

  Future<void> addOpenCloseDayData({
    required LegacyQueueModel model,
    required Function(ResponseStatus) voidCallBack,
    bool isPatient = false,
    String? doctorUid,
  }) async {
    Loader.show();
    final result = await useCase.addOpenCloseDay(
      model,
      isPatient: isPatient,
      doctorUid: _resolveDoctorUid(doctorUid),
    );

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> updateOpenCloseDayData({
    required LegacyQueueModel model,
    required Function(ResponseStatus) voidCallBack,
    bool isPatient = false,
    String? doctorUid,
  }) async {
    Loader.show();

    final result = await useCase.updateOpenCloseDay(
      model,
      isPatient: isPatient,
      doctorUid: _resolveDoctorUid(doctorUid),
    );

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> deleteOpenCloseDayData({
    required String date,
    required String key,
    required Function(ResponseStatus) voidCallBack,
    bool isPatient = false,
    String? doctorUid,
  }) async {
    Loader.show();

    final result = await useCase.deleteOpenCloseDay(
      date,
      key,
      isPatient: isPatient,
      doctorUid: _resolveDoctorUid(doctorUid),
    );

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }
}
