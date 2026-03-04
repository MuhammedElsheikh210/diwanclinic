import 'package:intl/intl.dart';

import '../../../../../../index/index_main.dart';

class ReservationViewModel extends GetxController {
  // Managers
  late final ReservationQueueManager queueManager;
  late final ReservationFilterManager filterManager;
  late final ReservationActionManager actionManager;
  late final ReservationQueryManager queryManager;
  bool hideShiftSelector = false;
  bool _isListening = false;
  bool _isProcessingStatus = false;

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
  }

  @override
  void onClose() {
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

          // 🔥 دايمًا اعمل normalize
          appointmentDate ??= DateFormat("dd/MM/yyyy").format(DateTime.now());

          final normalizedDate = AppDateFormatter.normalize(appointmentDate);

          if (!_isListening) {
            ReservationService().startListening(
              doctorKey: LocalUser().getUserData().doctorKey ?? "",
              date: normalizedDate,
              onChanged: (model) {
                _updateListInMemory(model);
              },
              onRemoved: (key) {
                completeDayReservations.removeWhere((e) => e?.key == key);
                listReservations?.removeWhere((e) => e?.key == key);
                update();
              },
            );
            _isListening = true;
          }

            await getReservations();


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

          if (shiftDropdownItems!.length == 1) {
            selectedShift = shiftDropdownItems!.first;

            appointmentDate ??= DateFormat("dd/MM/yyyy").format(DateTime.now());
            await getReservations();
            if (!_isListening) {
              ReservationService().startListening(
                doctorKey: LocalUser().getUserData().doctorKey ?? "",
                date: appointmentDate!,

                onChanged: (model) {
                  _updateListInMemory(model);
                },

                onRemoved: (key) {
                  completeDayReservations.removeWhere((e) => e?.key == key);
                  listReservations?.removeWhere((e) => e?.key == key);
                  update();
                },
              );

              _isListening = true;
            }
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

  void _updateListInMemory(ReservationModel model) {
    if (fromUpdate == true) {
      fromUpdate = false;
      return; // ignore any server echo for this change
    }

    listReservations ??= [];

    final dayIndex = completeDayReservations.indexWhere(
      (e) => e?.key == model.key,
    );

    if (dayIndex != -1) {
      completeDayReservations[dayIndex] = model;
    } else {
      completeDayReservations.insert(0, model);
    }

    final rebuilt = queueManager.buildFinalList(
      completeDayReservations.whereType<ReservationModel>().toList(),
    );

    listReservations = rebuilt;

    update();
  }

  Future<void> changeReservationStatus({
    required ReservationModel reservation,
    required ReservationStatus newStatus,
    String? cancelReason,
  }) async {
    if (_isProcessingStatus) return;

    _isProcessingStatus = true;
    Loader.show();

    try {
      reservation.status = newStatus.value;
      fromUpdate = true;

      await actionManager.updateReservation(reservation);

      _updateListInMemory(reservation);

      _runSideEffectsInBackground(reservation, newStatus, cancelReason);

      Loader.showSuccess("تم تحديث الحالة إلى ${newStatus.label}");
    } catch (e, stack) {
      debugPrint("❌ changeReservationStatus Error: $e");
      debugPrintStack(stackTrace: stack);

      Loader.showError("حدث خطأ أثناء تحديث الحالة");
    } finally {
      _isProcessingStatus = false;
      update();
    }
  }

  void _runSideEffectsInBackground(
    ReservationModel reservation,
    ReservationStatus newStatus,
    String? cancelReason,
  ) {
    unawaited(_handleSideEffects(reservation, newStatus, cancelReason));
  }

  Future<void> _handleSideEffects(
    ReservationModel reservation,
    ReservationStatus newStatus,
    String? cancelReason,
  ) async {
    try {
      // 1️⃣ Send Status Notification
      if (_shouldSendStatusNotification(newStatus)) {
        await _sendStatusNotification(reservation, newStatus, cancelReason);
      }

      // 2️⃣ Queue Update ONLY if completed
      if (newStatus == ReservationStatus.completed) {
        await _handleQueueUpdate();
      }
    } catch (e, stack) {
      debugPrint("❌ SideEffects Error: $e");
      debugPrintStack(stackTrace: stack);
    }
  }

  bool _shouldSendStatusNotification(ReservationStatus status) {
    return [
      ReservationStatus.approved,
      ReservationStatus.completed,
      ReservationStatus.cancelledByAssistant,
      ReservationStatus.cancelledByDoctor,
      ReservationStatus.cancelledByUser,
    ].contains(status);
  }

  Future<void> _sendStatusNotification(
    ReservationModel reservation,
    ReservationStatus newStatus,
    String? cancelReason,
  ) async {
    await NotificationHandler().sendStatusNotification(
      newStatus: newStatus,
      reservation: reservation,
      toToken: reservation.fcmToken_patient ?? "",
      cancelReason: cancelReason,
    );

    if (newStatus == ReservationStatus.completed ||
        newStatus == ReservationStatus.approved) {
      await WhatsAppStatusMessageService.sendStatusWhatsAppMessage(
        reservation: reservation,
        clinic: selectedClinic,
        newStatus: newStatus,
      );
    }
  }

  Future<void> _handleQueueUpdate() async {
    final snapshot = List<ReservationModel>.from(
      listReservations?.whereType<ReservationModel>().toList() ?? [],
    );

    await queueManager.notifyApprovedQueueUpdate(allReservations: snapshot);
  }

  Future<void> handleMakeOrder(ReservationModel reservation) async {
    Get.to(
      () => OrderMedicineScreen(
        reservation: reservation,
        onConfirmed: (ReservationModel p1) {
          actionManager.updateReservation(p1);
          Get.offAll(() => const MainPage(initialIndex: 2), binding: Binding());
        },
      ),
      binding: Binding(),
    );
  }
}

extension ReservationData on ReservationViewModel {
  // ============================================================
  // 🔹 Fetch Reservations (PARALLEL + SAFE)
  // ============================================================

  Future<void> getReservations() async {
    final doctorKey = LocalUser().getUserData().doctorKey;

    debugPrint("══════════════════════════════");
    debugPrint("📅 getReservations CALLED");
    debugPrint("DoctorKey: $doctorKey");
    debugPrint("AppointmentDate: $appointmentDate");
    debugPrint("SelectedShift: ${selectedShift?.key}");
    debugPrint("SelectedClinic: ${selectedClinic?.key}");
    debugPrint("══════════════════════════════");

    if (doctorKey == null ||
        doctorKey.isEmpty ||
        appointmentDate == null ||
        selectedShift == null) {
      debugPrint("⛔ getReservations ABORTED");
      return;
    }

    final normalizedDate = AppDateFormatter.normalize(appointmentDate);

    debugPrint("📅 Normalized Date: $normalizedDate");

    try {
      await Future.wait([
        fetchDailyReservations(normalizedDate),
        fetchFilteredReservations(normalizedDate),
        loadDailyReport(normalizedDate),
      ]);

      debugPrint("✅ All reservation queries finished");

      update();
    } catch (e, stack) {
      debugPrint("❌ getReservations ERROR: $e");
      debugPrintStack(stackTrace: stack);
    }
  }

  // ============================================================
  // 🔹 Fetch All Reservations For The Day
  // ============================================================

  Future<void> fetchDailyReservations(String normalizedDate) async {
    final daily = await queryManager.fetchByDateAndClinic(
      appointmentDate: normalizedDate,
      selectedClinic: selectedClinic,
      shiftKey: selectedShift!.key,
    );

    debugPrint("📊 Daily Reservations Count: ${daily.length}");

    completeDayReservations = daily;
  }

  // ============================================================
  // 🔹 Fetch Filtered Reservations
  // ============================================================

  Future<void> fetchFilteredReservations(String normalizedDate) async {
    final query = filterManager.buildFilters(
      selectedClinic: selectedClinic,
      appointmentDate: normalizedDate,
      selectedShift: selectedShift,
      selectedTab: selectedTab,
    );

    debugPrint("🧠 Filter Built: $query");

    final filtered = await queryManager.getReservations(query: query);

    debugPrint("📊 Filtered Reservations Count: ${filtered.length}");

    listReservations = queueManager.buildFinalList(filtered);

    debugPrint("📦 Final List Count: ${listReservations?.length}");
  }

  // ============================================================
  // 🔹 Daily Financial Report
  // ============================================================

  Future<void> loadDailyReport(String normalizedDate) async {
    if (selectedShift == null) return;

    completedForReport = await queryManager.getCompletedReservationsForReport(
      appointmentDate: normalizedDate,
      shiftKey: selectedShift!.key,
    );

    debugPrint(
      "💰 Completed Reservations For Report: ${completedForReport.length}",
    );
  }

  // ============================================================
  // 🔹 Total Reservations Today
  // ============================================================

  Future<int> getTotalTodayReservations() async {
    if (appointmentDate == null || selectedShift == null) {
      return 0;
    }

    final normalizedDate = AppDateFormatter.normalize(appointmentDate);

    final total = await queryManager.getTotalByDate(
      appointmentDate: normalizedDate,
      shiftKey: selectedShift!.key,
    );

    debugPrint("📊 Total Today Reservations: $total");

    return total;
  }

  // ============================================================
  // 🔹 Last Completed Reservation For Patient
  // ============================================================

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
