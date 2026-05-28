import 'package:dartz/dartz.dart';
import '../../Data/Models/doctor_announcement_model.dart';
import '../../index/index_main.dart';

abstract class DoctorAnnouncementRepository {
  Future<void> startListening({required String doctorKey, required String date});
  Future<void> dispose();

  Stream<DoctorAnnouncementModel> get onAdded;
  Stream<DoctorAnnouncementModel> get onChanged;
  Stream<String> get onRemoved;

  Future<Either<AppError, Unit>> createAnnouncementDomain(
    DoctorAnnouncementModel model,
  );

  Future<Either<AppError, DoctorAnnouncementModel?>> fetchLatestDomain({
    required String doctorKey,
    required String date,
  });

  Future<Either<AppError, Unit>> deactivatePreviousDomain({
    required String doctorKey,
    required String date,
  });
}
