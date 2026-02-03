import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class LegacyQueueUseCases {
  final LegacyQueueRepository _repository;

  LegacyQueueUseCases(this._repository);

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
}
