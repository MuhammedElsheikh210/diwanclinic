import '../../Data/Models/doctor_announcement_model.dart';

abstract class DoctorAnnouncementDataSource {
  Future<void> startListening({required String doctorKey, required String date});
  Future<void> stopListening();

  Stream<DoctorAnnouncementModel> get onAdded;
  Stream<DoctorAnnouncementModel> get onChanged;
  Stream<String> get onRemoved;

  Future<void> createAnnouncement(DoctorAnnouncementModel model);
  Future<void> deactivatePreviousAnnouncements({
    required String doctorKey,
    required String date,
  });
  Future<DoctorAnnouncementModel?> fetchLatestAnnouncement({
    required String doctorKey,
    required String date,
  });
}
