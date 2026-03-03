import '../../../../../../index/index_main.dart';
import 'dart:developer' as developer;

class ReservationViewModel extends GetxController {
  // Managers
  late final ReservationSyncService syncService;
  late final ReservationQueueManager queueManager;
  late final ReservationFilterManager filterManager;
  late final ReservationActionManager actionManager;
  late final ReservationQueryManager queryManager;
  bool hideShiftSelector = false;

  // Services
  final PrescriptionUploadService prescriptionService =
      PrescriptionUploadService();

  // UI State
  bool showDailyReport = false;
  bool? fromUpdate;
  bool isSyncing = false;
  bool _isInitialLoad = true;

  int selectedTab = 0;
  int completedReservation = 0;

  // Date + Patient
  String? appointmentDate;
  String? selectedPatientLastVisit;
  num? create_at;

  // Reservation Data
  List<ReservationModel?>? listReservations;
  List<ReservationModel?> completeDayReservations = [];
  List<ReservationModel> completedForReport = [];

  // Computed Stats
  int get completedCount =>
      completeDayReservations
          .where((r) => r?.status == ReservationStatus.completed.value)
          .length;

  int get waitingCount =>
      completeDayReservations
          .where(
            (r) =>
                r?.status == ReservationStatus.approved.value ||
                r?.status == ReservationStatus.inProgress.value,
          )
          .length;

  int get totalCount => completeDayReservations.length;

  // Clinic + Shift
  List<ClinicModel?>? listClinic;
  List<GenericListModel>? clinicDropdownItems;
  List<GenericListModel>? shiftDropdownItems;

  ClinicModel? selectedClinic;
  GenericListModel? selectedShift;

  // Filters
  ReservationNewStatus? selectedStatus;
  List<ReservationNewStatus>? selectedStatusesList;
  String? selectedType;

  final List<String> reservationTypeFilters = [
    "كشف جديد",
    "كشف مستعجل",
    "إعادة",
    "متابعة",
  ];

  // Lifecycle
  @override
  Future<void> onInit() async {
    super.onInit();
    _initManagers();
  }

  void _initManagers() {
    queueManager = ReservationQueueManager();
    filterManager = ReservationFilterManager();
    actionManager = ReservationActionManager();
    queryManager = ReservationQueryManager();
    syncService = ReservationSyncService(controller: this);
  }

  @override
  void onClose() {
    syncService.dispose();
    super.onClose();
  }

  // Fetch clinics
  Future<void> getClinicList() async {
    final clinicKey = LocalUser().getUserData().clinicKey ?? "";

    ClinicService().getClinicsData(
      data: {},
      filrebaseFilter: FirebaseFilter(),
      query: SQLiteQueryParams(
        is_filtered: clinicKey.isNotEmpty,
        where: clinicKey.isNotEmpty ? "key = ?" : null,
        whereArgs: clinicKey.isNotEmpty ? [clinicKey] : [],
      ),
      voidCallBack: (data) async {
        listClinic = data;
        Loader.dismiss();

        if (data.isNotEmpty) {
          clinicDropdownItems = ClinicAdapterUtil.convertClinicListToGeneric(
            data,
          );

          selectedClinic = data.first;
          await getShiftList();

          Future.delayed(const Duration(milliseconds: 300), () {
            _isInitialLoad = false;
          });
        }

        update();
      },
    );
  }

  void showMandatoryShiftDialog() {
    if (shiftDropdownItems == null || shiftDropdownItems!.isEmpty) return;

    Get.dialog(
      ShiftSelectionDialog(
        shifts: shiftDropdownItems!,
        initialSelected: selectedShift,
        onSelect: (shift) async {
          selectedShift = shift;

          await getReservations(isFilter: false);
          print("getSyncReservations call");
          getSyncReservations();

          update();
        },
      ),
      barrierDismissible: false, // 👈 مهم عشان يبقى mandatory
    );
  }

  Future<void> getShiftList() async {
    if (selectedClinic == null) return;

    ShiftService().getShiftsData(
      data: FirebaseFilter(orderBy: "clinicKey", equalTo: selectedClinic!.key),
      query: SQLiteQueryParams(
        is_filtered: true,
        where: "clinicKey = ?",
        whereArgs: [selectedClinic!.key],
      ),
      voidCallBack: (data) async {
        if (data != null && data.isNotEmpty) {
          shiftDropdownItems = ShiftModelAdapterUtil.convertShiftListToGeneric(
            data,
          );

          // ✅ حالة شيفت واحد فقط
          if (shiftDropdownItems!.length == 1) {
            selectedShift = shiftDropdownItems!.first;
            hideShiftSelector = true;

            await getReservations(isFilter: true);
            print("getSyncReservations call");
            getSyncReservations();
          }
          // ✅ أكثر من شيفت → افتح Dialog
          else {
            hideShiftSelector = false;

            Future.microtask(() {
              showMandatoryShiftDialog();
            });
          }
        } else {
          shiftDropdownItems = [];
          selectedShift = null;
        }

        update();
      },
    );
  }

  void getSyncReservations() {
    const tag = "VM_SYNC";

    SyncLogger.info(tag, "Starting Sync Engine (Memory Mode)");

    syncService.listen(
      selectedClinic: selectedClinic,
      appointmentDate: appointmentDate,

      // 🔹 Add
      onAddLocal: (model) async {
        SyncLogger.info(tag, "ADD → ${model.key}");

        await actionManager.addReservation(model, localOnly: true);

        _updateListInMemory(model);

        SyncLogger.success(tag, "ADD Completed → ${model.key}");
      },

      // 🔹 Update
      onUpdatedLocal: (model) async {
        SyncLogger.info(tag, "UPDATE → ${model.key}");

        await actionManager.updateReservation(
          model,
          isSyncing: true,
          localOnly: true,
        );

        _updateListInMemory(model);

        SyncLogger.success(tag, "UPDATE Completed → ${model.key}");
      },

      // ❌ مفيش Reload تاني
      onReloadLocal: () {
        SyncLogger.info(tag, "Reload skipped (Memory Mode Active)");
      },
    );
  }

  void _updateListInMemory(ReservationModel model) {
    const tag = "MEMORY_UPDATE";

    if (listReservations == null) {
      listReservations = [];
    }

    // حدث أو أضف في completeDayReservations
    final dayIndex = completeDayReservations.indexWhere(
      (e) => e?.key == model.key,
    );

    if (dayIndex != -1) {
      completeDayReservations[dayIndex] = model;
    } else {
      completeDayReservations.insert(0, model);
    }

    // 🔥 أعد بناء القائمة بالترتيب الصحيح
    final rebuilt = queueManager.buildFinalList(
      completeDayReservations.whereType<ReservationModel>().toList(),
    );

    listReservations = rebuilt;

    SyncLogger.success(tag, "Rebuilt list safely → ${model.key}");

    update();
  }

  // Change reservation status with optimized async handling + logging
  Future<void> changeReservationStatus({
    required ReservationModel reservation,
    required ReservationStatus newStatus,
    String? cancelReason,
  }) async {
    Loader.show();

    const String tag = "ReservationStatusChange";
    final startTime = DateTime.now();

    debugPrint("[$tag] 🔄 Start changing status to: ${newStatus.value}");
    debugPrint("[$tag] Reservation ID: ${reservation.key}");

    try {
      // 1️⃣ Update locally
      reservation.status = newStatus.value;
      fromUpdate = true;

      // 2️⃣ Persist in DB (THIS must await)
      await actionManager.updateReservation(reservation, isSyncing: false);

      debugPrint("[$tag] ✅ DB updated successfully");

      // 3️⃣ Reload UI data (must await)
      // await getReservations(isFilter: false);
      _updateListInMemory(reservation);

      debugPrint("[$tag] 🔁 Reservations reloaded");

      // 4️⃣ Run side effects in background (no await)
      _runSideEffectsInBackground(reservation, newStatus, cancelReason);

      Loader.showSuccess("تم تحديث الحالة إلى ${newStatus.label}");
    } catch (e, stack) {
      debugPrint("[$tag] ❌ ERROR: $e");
      debugPrint("[$tag] Stack: $stack");
      Loader.showError("حدث خطأ أثناء تحديث الحالة");
    }

    final duration = DateTime.now().difference(startTime);
    debugPrint("[$tag] ⏱ Completed in ${duration.inMilliseconds}ms");

    update();
  }

  void _runSideEffectsInBackground(
    ReservationModel reservation,
    ReservationStatus newStatus,
    String? cancelReason,
  ) {
    const String tag = "ReservationSideEffects";

    Future.microtask(() async {
      try {
        debugPrint("[$tag] 🚀 Running side effects for ${newStatus.value}");

        switch (newStatus) {
          case ReservationStatus.approved:
          case ReservationStatus.completed:
            await NotificationHandler().sendStatusNotification(
              newStatus: newStatus,
              reservation: reservation,
              toToken: reservation.fcmToken_patient ?? "",
            );

            await WhatsAppStatusMessageService.sendStatusWhatsAppMessage(
              reservation: reservation,
              clinic: selectedClinic,
              newStatus: newStatus,
            );
            break;

          case ReservationStatus.cancelledByAssistant:
          case ReservationStatus.cancelledByDoctor:
          case ReservationStatus.cancelledByUser:
            await NotificationHandler().sendStatusNotification(
              newStatus: newStatus,
              reservation: reservation,
              toToken: reservation.fcmToken_patient ?? "",
              cancelReason: cancelReason,
            );
            break;

          default:
            break;
        }

        // Queue update only if completed
        if (newStatus == ReservationStatus.completed) {
          await queueManager.notifyApprovedQueueUpdate(
            allReservations:
                listReservations?.whereType<ReservationModel>().toList() ?? [],
          );
        }

        debugPrint("[$tag] ✅ Side effects completed");
      } catch (e, stack) {
        debugPrint("[$tag] ❌ Background error: $e");
        debugPrint("[$tag] Stack: $stack");
      }
    });
  }

  Future<void> handleMakeOrder(ReservationModel reservation) async {
    Get.to(
      () => OrderMedicineScreen(
        reservation: reservation,
        onConfirmed: (ReservationModel p1) {
          actionManager.updateReservation(p1, isSyncing: false);
          Get.offAll(() => const MainPage(initialIndex: 2), binding: Binding());
        },
      ),
      binding: Binding(),
    );
  }
}

extension ReservationData on ReservationViewModel {
  // ------------------------------------------------------------
  // Fetch reservations
  Future<void> getReservations({
    bool? isFilter = false,
    bool? fromOnline,
  }) async {
    const tag = "GET_RESERVATIONS";
    final startTime = DateTime.now();

    SyncLogger.info(
      tag,
      "Started | Date: $appointmentDate | Shift: ${selectedShift?.key} | "
      "Clinic: ${selectedClinic?.key} | fromOnline: $fromOnline | isFilter: $isFilter",
    );

    if (appointmentDate == null || selectedShift == null) {
      SyncLogger.warning(
        tag,
        "Blocked → appointmentDate or selectedShift is NULL",
      );
      return;
    }

    try {
      // 🔹 1) Fetch full day list
      SyncLogger.info(tag, "Fetching full day reservations...");

      final daily = await queryManager.fetchAllReservationsOfDay(
        appointmentDate: appointmentDate,
        selectedClinic: selectedClinic,
        shiftKey: selectedShift!.key,
        isFiltered: false,
        fromOnline: fromOnline,
      );

      completeDayReservations = daily;

      SyncLogger.success(tag, "Full Day Loaded → count: ${daily.length}");

      // 🔹 2) Build filters
      SyncLogger.info(tag, "Building filter query...");

      final query = filterManager.buildFilters(
        selectedClinic: selectedClinic,
        appointmentDate: appointmentDate,
        selectedShift: selectedShift,
        selectedTab: selectedTab,
        isFiltered: isFilter ?? false,
      );

      // 🔹 3) Apply filtered list
      SyncLogger.info(tag, "Fetching filtered reservations...");

      final filtered = await queryManager.getReservations(
        appointmentDate: appointmentDate,
        query: query,
        isFiltered: false,
        fromOnline: fromOnline,
      );

      listReservations = queueManager.buildFinalList(filtered);

      SyncLogger.success(
        tag,
        "Filtered Loaded → count: ${listReservations?.length ?? 0}",
      );

      // 🔹 4) Load report
      SyncLogger.info(tag, "Loading daily report...");

      await loadDailyReport(fromOnline: fromOnline ?? false);

      SyncLogger.success(
        tag,
        "Daily Report Loaded → completed: ${completedForReport.length}",
      );

      final duration = DateTime.now().difference(startTime);

      SyncLogger.success(
        tag,
        "Completed Successfully in ${duration.inMilliseconds} ms",
      );

      update();
    } catch (e, stack) {
      SyncLogger.error(tag, "Failed to load reservations", e);
      SyncLogger.error(tag, "StackTrace", stack);
    }
  }

  // ------------------------------------------------------------
  // Load daily financial report
  Future<void> loadDailyReport({bool? fromOnline}) async {
    if (appointmentDate == null || selectedShift == null) return;

    completedForReport = await queryManager.getCompletedReservationsForReport(
      appointmentDate: appointmentDate,
      shiftKey: selectedShift!.key,
      isFiltered: false,
      fromOnline: fromOnline,
    );
  }

  // ------------------------------------------------------------
  // Get total reservations count
  Future<int> getTotalTodayReservations() async {
    if (appointmentDate == null || selectedShift == null) {
      return 0;
    }

    return await queryManager.getTotalByDate(
      appointmentDate: appointmentDate,
      shiftKey: selectedShift!.key,
      isFiltered: false,
    );
  }

  // ------------------------------------------------------------
  // Get last visit for patient
  Future<void> getLastReservationDateForPatient(LocalUser client) async {
    selectedPatientLastVisit = null;
    update();

    final reservation = await queryManager.getLastCompletedForPatient(
      client.key!,
    );

    selectedPatientLastVisit =
        reservation == null
            ? "لا يوجد كشف سابق"
            : DatesUtilis.humanizeTimestamp(reservation.createAt);

    update();
  }
}

class SyncLogger {
  static const bool enableLogs = true;

  static void _log(
    String level,
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!enableLogs) return;

    final time = DateTime.now().toIso8601String();

    developer.log(
      "[$time] [$level] [$tag] $message",
      name: "SYNC_ENGINE",
      error: error,
      stackTrace: stackTrace,
    );
  }

  // ─────────────────────────────────────────────
  // 🔹 Levels
  // ─────────────────────────────────────────────

  static void info(String tag, String message) {
    _log("INFO", tag, message);
  }

  static void success(String tag, String message) {
    _log("SUCCESS", tag, message);
  }

  static void warning(String tag, String message) {
    _log("WARNING", tag, message);
  }

  static void error(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log("ERROR", tag, message, error: error, stackTrace: stackTrace);
  }

  // ─────────────────────────────────────────────
  // 🔥 Performance Helper
  // ─────────────────────────────────────────────

  static Stopwatch startTimer() {
    final stopwatch = Stopwatch()..start();
    return stopwatch;
  }

  static void endTimer(String tag, String label, Stopwatch stopwatch) {
    stopwatch.stop();
    _log("PERFORMANCE", tag, "$label took ${stopwatch.elapsedMilliseconds} ms");
  }
}
