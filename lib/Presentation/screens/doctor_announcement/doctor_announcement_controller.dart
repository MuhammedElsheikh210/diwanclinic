import '../../../index/index_main.dart';

/// GetX controller that bridges [DoctorAnnouncementService] with the UI.
/// Initialized once per session from [ReservationViewModel] or any screen
/// that knows the active doctorKey.
class DoctorAnnouncementController extends GetxController {
  final DoctorAnnouncementService _service = DoctorAnnouncementService();

  DoctorAnnouncementModel? get activeAnnouncement =>
      _service.activeAnnouncement;

  bool isCreating = false;

  @override
  void onInit() {
    super.onInit();
    _service.addListener(_onServiceUpdate);
  }

  @override
  void onClose() {
    _service.removeListener(_onServiceUpdate);
    super.onClose();
  }

  void _onServiceUpdate() => update();

  // ============================================================
  // 🚀 INIT WITH DOCTOR KEY
  // ============================================================

  Future<void> initForDoctor(String doctorKey) async {
    await _service.init(doctorKey: doctorKey);
    update();
  }

  // ============================================================
  // ➕ CREATE ANNOUNCEMENT
  // ============================================================

  Future<bool> createAnnouncement({
    required DoctorAnnouncementType type,
    required String doctorKey,
    required String doctorName,
    String? reason,
    String? estimatedTime,
  }) async {
    isCreating = true;
    update();

    final success = await _service.createAnnouncement(
      type: type,
      doctorKey: doctorKey,
      doctorName: doctorName,
      reason: reason,
      estimatedTime: estimatedTime,
    );

    isCreating = false;
    update();

    return success;
  }

  // ============================================================
  // 🔍 HELPERS
  // ============================================================

  bool get hasActiveAnnouncement => activeAnnouncement != null;

  bool get isDoctorUnavailable =>
      activeAnnouncement?.announcementType.isUnavailable ?? false;

  bool get canCreate {
    final userType = Get.find<UserSession>().user?.user.userType;
    return userType == UserType.doctor || userType == UserType.assistant;
  }
}
