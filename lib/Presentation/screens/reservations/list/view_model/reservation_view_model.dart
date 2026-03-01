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

          await getReservations(isFilter: true);
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

    bool isReloading = false;

    SyncLogger.info(tag, "Starting sync listener");
    SyncLogger.info(
      tag,
      "Clinic: ${selectedClinic?.key} | Date: $appointmentDate",
    );

    syncService.listen(
      selectedClinic: selectedClinic,
      appointmentDate: appointmentDate,

      onAddLocal: (model) async {
        SyncLogger.info(tag, "onAddLocal -> ${model.key}");

        try {
          await actionManager.addReservation(model, localOnly: true);

          SyncLogger.success(tag, "Added locally -> ${model.key}");

          _updateListInMemory(model);
        } catch (e) {
          SyncLogger.error(tag, "Error in onAddLocal", e);
        }
      },

      onUpdatedLocal: (model) async {
        SyncLogger.info(tag, "onUpdatedLocal -> ${model.key}");

        try {
          await actionManager.updateReservation(
            model,
            isSyncing: true,
            localOnly: true,
          );

          SyncLogger.success(tag, "Updated locally -> ${model.key}");

          _updateListInMemory(model);
        } catch (e) {
          SyncLogger.error(tag, "Error in onUpdatedLocal", e);
        }
      },

      onReloadLocal: () {
        if (isReloading) {
          SyncLogger.warning(tag, "Reload skipped (already reloading)");
          return;
        }

        if (isSyncing) {
          SyncLogger.warning(tag, "Reload skipped (still syncing)");
          return;
        }

        SyncLogger.info(tag, "Reload triggered");

        isReloading = true;

        Future.microtask(() async {
          try {
            await getReservations(isFilter: false);
            SyncLogger.success(tag, "Reload completed");
          } catch (e) {
            SyncLogger.error(tag, "Reload failed", e);
          }

          isReloading = false;
        });
      },
    );
  }

  void _updateListInMemory(ReservationModel model) {
    final index =
        listReservations?.indexWhere((e) => e?.key == model.key) ?? -1;

    if (index != -1) {
      listReservations![index] = model;
    } else {
      listReservations?.insert(0, model);
    }

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
      await getReservations(isFilter: false);

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
    if (appointmentDate == null || selectedShift == null) return;

    // 🔹 1) Get full day reservations (with shift filter)
    final daily = await queryManager.fetchAllReservationsOfDay(
      appointmentDate: appointmentDate,
      selectedClinic: selectedClinic,
      shiftKey: selectedShift!.key,
      isFiltered: isFilter ?? false,
      fromOnline: fromOnline,
    );

    completeDayReservations = daily;

    // 🔹 2) Build local filter query (already includes shift)
    final query = filterManager.buildFilters(
      selectedClinic: selectedClinic,
      appointmentDate: appointmentDate,
      selectedShift: selectedShift,
      selectedTab: selectedTab,
      isFiltered: isFilter ?? false,
    );

    // 🔹 3) Apply filtered list
    final filtered = await queryManager.getReservations(
      appointmentDate: appointmentDate,
      query: query,
      isFiltered: isFilter ?? false,
      fromOnline: fromOnline,
    );

    listReservations = queueManager.buildFinalList(filtered);

    // 🔹 4) Load report
    await loadDailyReport(fromOnline: fromOnline ?? false);

    update();
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

  static void _log(String level, String tag, String message) {
    if (!enableLogs) return;

    final time = DateTime.now().toIso8601String();

    developer.log("[$time] [$level] [$tag] $message", name: "SYNC_ENGINE");
  }

  static void info(String tag, String message) {
    _log("INFO", tag, message);
  }

  static void success(String tag, String message) {
    _log("SUCCESS", tag, message);
  }

  static void warning(String tag, String message) {
    _log("WARNING", tag, message);
  }

  static void error(String tag, String message, [Object? error]) {
    _log("ERROR", tag, "$message | $error");
  }
}
