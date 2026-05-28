import 'package:dartz/dartz.dart';
import '../../Data/Models/doctor_announcement_model.dart';
import '../../Domain/Repositories/doctor_announcement_repository.dart';
import '../../index/index_main.dart';

class DoctorAnnouncementUseCases {
  final DoctorAnnouncementRepository _repository;

  DoctorAnnouncementUseCases(this._repository);

  Future<void> startListening({
    required String doctorKey,
    required String date,
  }) {
    return _repository.startListening(doctorKey: doctorKey, date: date);
  }

  Future<void> dispose() => _repository.dispose();

  Stream<DoctorAnnouncementModel> get onAdded => _repository.onAdded;
  Stream<DoctorAnnouncementModel> get onChanged => _repository.onChanged;
  Stream<String> get onRemoved => _repository.onRemoved;

  Future<Either<AppError, Unit>> createAnnouncement(
    DoctorAnnouncementModel model,
  ) {
    return _repository.createAnnouncementDomain(model);
  }

  Future<Either<AppError, DoctorAnnouncementModel?>> fetchLatest({
    required String doctorKey,
    required String date,
  }) {
    return _repository.fetchLatestDomain(doctorKey: doctorKey, date: date);
  }

  Future<Either<AppError, Unit>> deactivatePrevious({
    required String doctorKey,
    required String date,
  }) {
    return _repository.deactivatePreviousDomain(
      doctorKey: doctorKey,
      date: date,
    );
  }
}
