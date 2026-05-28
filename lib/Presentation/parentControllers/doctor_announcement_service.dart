import '../../index/index_main.dart';

/// Singleton service that manages the active doctor announcement for today.
/// Shared across all screens — any screen can observe [activeAnnouncement].
class DoctorAnnouncementService {
  static final DoctorAnnouncementService _instance =
      DoctorAnnouncementService._internal();

  factory DoctorAnnouncementService() => _instance;

  DoctorAnnouncementService._internal();

  final DoctorAnnouncementUseCases _useCases = initController(
    () => DoctorAnnouncementUseCases(Get.find()),
  );

  // ============================================================
  // 🔥 STATE
  // ============================================================

  DoctorAnnouncementModel? activeAnnouncement;
  String? _currentDoctorKey;
  bool _isListening = false;
  bool _isDisposed = false;

  StreamSubscription? _addedSub;
  StreamSubscription? _changedSub;
  StreamSubscription? _removedSub;

  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);
  void _notify() {
    for (final l in _listeners) {
      l();
    }
  }

  // ============================================================
  // 🚀 INIT — called once per doctor per day
  // ============================================================

  Future<void> init({required String doctorKey}) async {
    if (_isDisposed) return;

    // If already listening to the same doctor, skip re-init
    if (_isListening && _currentDoctorKey == doctorKey) return;

    // Stop previous listener if switching doctors
    if (_isListening) await _stopListening();

    _currentDoctorKey = doctorKey;

    final today = _todayString();

    // Load current announcement immediately
    final result = await _useCases.fetchLatest(
      doctorKey: doctorKey,
      date: today,
    );
    result.fold(
      (_) {},
      (model) {
        activeAnnouncement = model;
        _notify();
      },
    );

    // Start real-time listener
    await _useCases.startListening(doctorKey: doctorKey, date: today);

    _addedSub = _useCases.onAdded.listen(_onAnnouncement);
    _changedSub = _useCases.onChanged.listen(_onAnnouncement);
    _removedSub = _useCases.onRemoved.listen(_onRemoved);

    _isListening = true;
    AppLogger.success("ANNOUNCEMENT", "Service initialized for $doctorKey");
  }

  // ============================================================
  // ➕ CREATE ANNOUNCEMENT
  // Deactivates old → writes new → notifies patients
  // ============================================================

  Future<bool> createAnnouncement({
    required DoctorAnnouncementType type,
    required String doctorKey,
    required String doctorName,
    String? reason,
    String? estimatedTime,
  }) async {
    if (_isDisposed) return false;

    final today = _todayString();

    // 1. Deactivate all previous announcements for today
    await _useCases.deactivatePrevious(doctorKey: doctorKey, date: today);

    // 2. Create new announcement — Firebase Function handles patient notifications
    final model = DoctorAnnouncementModel.create(
      type: type,
      doctorKey: doctorKey,
      doctorName: doctorName,
      reason: reason,
      estimatedTime: estimatedTime,
    );

    final result = await _useCases.createAnnouncement(model);

    return result.fold(
      (err) {
        AppLogger.error("ANNOUNCEMENT", "Create failed", err);
        return false;
      },
      (_) {
        activeAnnouncement = model;
        _notify();
        AppLogger.success("ANNOUNCEMENT", "Created: ${type.arabicLabel}");
        return true;
      },
    );
  }

  // ============================================================
  // 🔁 REALTIME HANDLERS
  // ============================================================

  void _onAnnouncement(DoctorAnnouncementModel model) {
    // Only update if this is the latest active one
    final current = activeAnnouncement;
    if (model.isActive == true) {
      if (current == null ||
          (model.createdAt ?? 0) >= (current.createdAt ?? 0)) {
        activeAnnouncement = model;
        _notify();
        AppLogger.info("ANNOUNCEMENT", "Active: ${model.announcementType.arabicLabel}");
      }
    } else if (model.key == current?.key) {
      // Current one was deactivated
      activeAnnouncement = null;
      _notify();
    }
  }

  void _onRemoved(String key) {
    if (activeAnnouncement?.key == key) {
      activeAnnouncement = null;
      _notify();
    }
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  Future<void> _stopListening() async {
    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();
    _addedSub = null;
    _changedSub = null;
    _removedSub = null;
    _isListening = false;
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _stopListening();
    await _useCases.dispose();
    _listeners.clear();
    AppLogger.warning("ANNOUNCEMENT", "Service disposed");
  }

  // ============================================================
  // 🗓️ HELPERS
  // ============================================================

  String _todayString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}
