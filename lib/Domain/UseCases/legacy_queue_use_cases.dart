import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class LegacyQueueUseCases {
  final LegacyQueueRepository _repository;

  LegacyQueueUseCases(this._repository);

  // ------------------------------------------------------------
  // 🧾 Legacy Queue (الكشوفات الورقية)
  // ------------------------------------------------------------
  Future<Either<AppError, SuccessModel>> addLegacyQueue(
      LegacyQueueModel model, {
        bool isPatient = false,
        String? doctorUid,
      }) {
    return _repository.addLegacyQueueDomain(
      model.date ?? "",
      model.key ?? "",
      model.toJson(),
      isPatient: isPatient,
      doctorUid: doctorUid,
    );
  }

  Future<Either<AppError, SuccessModel>> updateLegacyQueue(
      LegacyQueueModel model, {
        bool isPatient = false,
        String? doctorUid,
      }) {
    return _repository.updateLegacyQueueDomain(
      model.date ?? "",
      model.key ?? "",
      model.toJson(),
      isPatient: isPatient,
      doctorUid: doctorUid,
    );
  }

  Future<Either<AppError, SuccessModel>> deleteLegacyQueue(
      String date,
      String key, {
        bool isPatient = false,
        String? doctorUid,
      }) {
    return _repository.deleteLegacyQueueDomain(
      date,
      key,
      isPatient: isPatient,
      doctorUid: doctorUid,
      isOpenCloseFeature: false,
    );
  }

  Future<Either<AppError, List<LegacyQueueModel?>>> getLegacyQueueByDate(
      String date,
      Map<String, dynamic> params, {
        bool isPatient = false,
        String? doctorUid,
      }) {
    return _repository.getLegacyQueueByDateDomain(
      date,
      params,
      isPatient: isPatient,
      doctorUid: doctorUid,
    );
  }

  // ------------------------------------------------------------
  // 🔒 Open / Close Days (WITH SHIFT)
  // ------------------------------------------------------------
  Future<Either<AppError, List<LegacyQueueModel?>>>
  getOpenCloseDaysByDate(
      String date, {
        required String shiftKey, // ✅ مهم
        bool isPatient = false,
        String? doctorUid,
      }) {
    return _repository.getOpenCloseDaysByDateDomain(
      date,
      shiftKey: shiftKey,
      isPatient: isPatient,
      doctorUid: doctorUid,
    );
  }

  Future<Either<AppError, SuccessModel>> addOpenCloseDay(
      LegacyQueueModel model, {
        required String shiftKey, // ✅ مهم
        bool isPatient = false,
        String? doctorUid,
      }) {
    return _repository.addLegacyQueueDomain(
      model.date ?? "",
      model.key ?? "",
      model.toJson(),
      isPatient: isPatient,
      doctorUid: doctorUid,
      shiftKey: shiftKey,
    );
  }

  Future<Either<AppError, SuccessModel>> updateOpenCloseDay(
      LegacyQueueModel model, {
        required String shiftKey, // ✅ مهم
        bool isPatient = false,
        String? doctorUid,
      }) {
    return _repository.updateLegacyQueueDomain(
      model.date ?? "",
      model.key ?? "",
      model.toJson(),
      isPatient: isPatient,
      doctorUid: doctorUid,
      shiftKey: shiftKey,
    );
  }

  Future<Either<AppError, SuccessModel>> deleteOpenCloseDay(
      String date,
      String key, {
        required String shiftKey, // ✅ مهم
        bool isPatient = false,
        String? doctorUid,
      }) {
    return _repository.deleteLegacyQueueDomain(
      date,
      key,
      isPatient: isPatient,
      doctorUid: doctorUid,
      isOpenCloseFeature: true,
      shiftKey: shiftKey,
    );
  }
}