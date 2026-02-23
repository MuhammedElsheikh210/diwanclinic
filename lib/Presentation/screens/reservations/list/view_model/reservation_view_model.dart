import '../../../../../../index/index_main.dart';

class ReservationViewModel extends GetxController {
  // Managers
  late final ReservationSyncService syncService;
  late final ReservationQueueManager queueManager;
  late final ReservationFilterManager filterManager;
  late final ReservationActionManager actionManager;
  late final ReservationQueryManager queryManager;

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
  int get completedCount => completeDayReservations
      .where((r) => r?.status == ReservationStatus.completed.value)
      .length;

  int get waitingCount => completeDayReservations
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

  // Fetch reservations
  Future<void> getReservations({
    bool? isFilter = false,
    bool? fromOnline,
  }) async {
    if (appointmentDate == null) return;

    final daily = await queryManager.fetchAllReservationsOfDay(
      appointmentDate: appointmentDate,
      selectedClinic: selectedClinic,
      isFiltered: false,
    );

    completeDayReservations = daily;

    final query = filterManager.buildFilters(
      selectedClinic: selectedClinic,
      appointmentDate: appointmentDate,
      selectedShift: selectedShift,
      selectedTab: selectedTab,
      isFiltered: isFilter ?? false,
    );
    print("query is ${query}");

    final filtered = await queryManager.getReservations(
      appointmentDate: appointmentDate,
      query: query,
      isFiltered: false,
    );

    listReservations = queueManager.buildFinalList(filtered);

    await loadDailyReport(fromOnline: fromOnline ?? true);

    update();
  }

  // Load daily financial report
  Future<void> loadDailyReport({bool? fromOnline}) async {
    if (appointmentDate == null) return;

    completedForReport = await queryManager.getCompletedReservationsForReport(
      appointmentDate: appointmentDate,
      isFiltered: false,
    );
  }

  // Get total reservations count
  Future<int> getTotalTodayReservations() {
    return queryManager.getTotalByDate(appointmentDate: appointmentDate);
  }

  // Get last visit for patient
  Future<void> getLastReservationDateForPatient(LocalUser client) async {
    selectedPatientLastVisit = null;
    update();

    final reservation = await queryManager.getLastCompletedForPatient(
      client.key!,
    );

    selectedPatientLastVisit = reservation == null
        ? "لا يوجد كشف سابق"
        : DatesUtilis.humanizeTimestamp(reservation.createAt);

    update();
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

  Future<void> getShiftList() async {
    if (selectedClinic == null) return;

    ShiftService().getShiftsData(
      data: FirebaseFilter(orderBy: "clinicKey", equalTo: selectedClinic!.key),
      query: SQLiteQueryParams(
        is_filtered: true,
        where: "clinicKey = ?",
        whereArgs: [selectedClinic!.key],
      ),
      voidCallBack: (data) {
        if (data != null && data.isNotEmpty) {
          shiftDropdownItems = ShiftModelAdapterUtil.convertShiftListToGeneric(
            data,
          );

          selectedShift = shiftDropdownItems!.first;
          getReservations(isFilter: true);
          getSyncReservations(initLocalData: true);
        } else {
          shiftDropdownItems = [];
          selectedShift = null;
        }

        update();
      },
    );
  }

  void getSyncReservations({bool? initLocalData}) {
    syncService.listen(
      selectedClinic: selectedClinic,
      appointmentDate: appointmentDate,

      onAddLocal: (model) async {
        initLocalData = null;
        await actionManager.addReservation(model, localOnly: true);
      },

      onUpdatedLocal: (model) async {
        initLocalData = null;
        await actionManager.updateReservation(
          model,
          isSyncing: true,
          localOnly: true,
        );
      },

      onReloadLocal: () {
        // pass true in get clinic to not make call here
        print("call here");
        if (initLocalData == null) {
          getReservations(isFilter: false);
        }
      },
    );
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
