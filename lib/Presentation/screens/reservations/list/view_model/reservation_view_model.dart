import 'package:intl/intl.dart';

import '../../../../../../index/index_main.dart';

class ReservationViewModel extends GetxController {
  // Managers
  late final ReservationQueueManager queueManager;
  late final ReservationFilterManager filterManager;
  late final ReservationActionManager actionManager;
  late final ReservationQueryManager queryManager;
  late final ReservationCheckInManager checkInManager;
  late final ReservationServingManager servingManager;
  late final ReservationQueueReasonManager queueReasonManager;
  late final ReservationSnapshotManager snapshotManager;
  bool hideShiftSelector = false;
  bool _isProcessingStatus = false;
  List<ReservationModel> _cachedReservations = [];
  int _activeNewbornCount = 0;

  // Services
  final PrescriptionUploadService prescriptionService =
      PrescriptionUploadService();

  // UI State
  bool showDailyReport = true;
  bool isSyncing = false;

  int selectedTab = 0;
  int completedReservation = 0;
  String searchQuery = "";

  // Date + Patient
  String? appointmentDate;
  String? selectedPatientLastVisit;
  num? create_at;

  // Reservation Data
  List<ReservationModel?>? listReservations;
  List<ReservationModel?> completeDayReservations = [];
  List<ReservationModel> completedForReport = [];
  List<LocalUser?>? centerDoctors;
  LocalUser? selectedDoctor;
  bool isLoadingDoctors = false;

  bool get isCenterMode => false;

  List<ReservationModel?> get filteredReservations {
    final q = searchQuery.trim();
    if (q.isEmpty) return listReservations ?? [];
    // Search across ALL of today's reservations (all statuses/types, not just the active tab)
    return completeDayReservations.where((r) {
      if (r == null) return false;
      final orderMatch = r.orderNum?.toString() == q;
      final phoneMatch = (r.patientPhone ?? "").contains(q);
      return orderMatch || phoneMatch;
    }).toList();
  }

  bool get hasActiveUrgentReservation {
    const doneStatuses = {
      "completed",
      "cancelled_by_user",
      "cancelled_by_assistant",
      "cancelled_by_doctor",
      "missed",
    };
    return completeDayReservations.any(
      (r) =>
          r != null &&
          r.reservationType == "كشف مستعجل" &&
          !doneStatuses.contains(r.status),
    );
  }

  int totalCount = 0;
  int completedCount = 0;
  int waitingCount = 0;

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

  final List<String> reservationTypeFilters = ["جديد", "مستعجل", "إعادة"];

  @override
  Future<void> onInit() async {
    super.onInit();
    if (isCenterMode) {
      loadDoctorsOfCenter();
    } else {
      getClinicList();
    }
    _initManagers();
    _listenToGlobalReservationEvents();
    _initAnnouncementService();
  }

  void _initAnnouncementService() {
    final doctorKey = ApiConstatns.uid;
    if (doctorKey == null || doctorKey.isEmpty) return;

    final announcementController = Get.find<DoctorAnnouncementController>();
    announcementController.initForDoctor(doctorKey);
  }

  void calculateStats() {
    final list = completeDayReservations;

    totalCount = list.length;

    completedCount =
        list
            .where((r) => r?.status == ReservationStatus.completed.value)
            .length;

    waitingCount =
        list
            .where(
              (r) =>
                  r?.status == ReservationStatus.approved.value ||
                  r?.status == ReservationStatus.checkedIn.value ||
                  r?.status == ReservationStatus.inProgress.value,
            )
            .length;
  }

  Future<void> loadDoctorsOfCenter() async {
    // final centerKey = LocalUser().getUserData().medicalCenterKey;
    // if (centerKey == null) return;
    //
    // isLoadingDoctors = true;
    // update();
    //
    // AuthenticationService().getClientsData(
    //   query: SQLiteQueryParams(
    //     where: "medicalCenterKey = ? AND userType = ?",
    //     whereArgs: [centerKey, "doctor"],
    //   ),
    //   voidCallBack: (data) async {
    //     centerDoctors = data;
    //
    //     // ✅ اختار أول دكتور تلقائيًا
    //     if (data.isNotEmpty) {
    //       selectedDoctor = data.first;
    //
    //       final doctorKey = selectedDoctor?.uid ?? "";
    //       MainPageViewModel mainPageViewModel = initController(
    //         () => MainPageViewModel(),
    //       );
    //       // 🔥 start realtime reservations
    //       await mainPageViewModel.startReservationsRealtime(
    //         doctorKey: doctorKey,
    //       );
    //
    //       // 📍 تحميل العيادات
    //       await getClinicList();
    //     }
    //
    //     isLoadingDoctors = false;
    //     update();
    //   },
    // );
  }

  void _initManagers() {
    queueManager = ReservationQueueManager();
    filterManager = ReservationFilterManager();
    actionManager = ReservationActionManager();
    queryManager = ReservationQueryManager();
    checkInManager = ReservationCheckInManager();
    servingManager = ReservationServingManager();
    queueReasonManager = ReservationQueueReasonManager();
    snapshotManager = ReservationSnapshotManager();
  }

  /// Check patient in at the clinic.
  Future<void> checkInPatient(ReservationModel reservation) async {
    if (_isProcessingStatus) return;
    _isProcessingStatus = true;
    Loader.show();
    try {
      await checkInManager.checkIn(
        reservation: reservation,
        onSuccess: (updated) {
          _updateListInMemory(updated);
          unawaited(_handleQueueUpdate(snapshotReason: QueueChangeReason.checkedIn));
          unawaited(queueReasonManager.writeReason(
            reservation: updated,
            reason: QueueChangeReason.checkedIn,
          ));
          Loader.showSuccess("تم تسجيل حضور المريض");
        },
      );
    } catch (e) {
      Loader.showError("حدث خطأ أثناء تسجيل الحضور");
    } finally {
      _isProcessingStatus = false;
      update();
    }
  }

  /// Mark patient as missed (no-show).
  Future<void> markPatientMissed(ReservationModel reservation) async {
    if (_isProcessingStatus) return;
    _isProcessingStatus = true;
    Loader.show();
    try {
      await checkInManager.markMissed(
        reservation: reservation,
        onSuccess: () {
          reservation.status = ReservationStatus.missed.value;
          _updateListInMemory(reservation);
          unawaited(_handleQueueUpdate(snapshotReason: QueueChangeReason.windowShift));
          Loader.showSuccess("تم تسجيل الغياب");
        },
      );
    } catch (e) {
      Loader.showError("حدث خطأ");
    } finally {
      _isProcessingStatus = false;
      update();
    }
  }

  /// Return a missed patient to the active queue.
  /// They re-enter within the same window but with lower priority.
  Future<void> returnMissedPatient(ReservationModel reservation) async {
    if (_isProcessingStatus) return;
    _isProcessingStatus = true;
    Loader.show();
    try {
      await checkInManager.returnFromMissed(
        reservation: reservation,
        onSuccess: (updated) {
          _updateListInMemory(updated);
          unawaited(_handleQueueUpdate(snapshotReason: QueueChangeReason.missedReturned));
          unawaited(queueReasonManager.writeReason(
            reservation: updated,
            reason: QueueChangeReason.missedReturned,
          ));
          Loader.showSuccess("تم إعادة المريض إلى الطابور");
        },
      );
    } catch (e) {
      Loader.showError("حدث خطأ أثناء إعادة المريض");
    } finally {
      _isProcessingStatus = false;
      update();
    }
  }

  /// Manually promote a patient who has been waiting too long.
  Future<void> promotePatient(
    ReservationModel reservation, {
    int minWaitMinutes = 60,
  }) async {
    if (_isProcessingStatus) return;
    _isProcessingStatus = true;
    try {
      await checkInManager.manualPromote(
        reservation: reservation,
        minWaitMinutes: minWaitMinutes,
        onSuccess: (updated) {
          _updateListInMemory(updated);
          unawaited(_handleQueueUpdate(snapshotReason: QueueChangeReason.manualPromote));
          unawaited(queueReasonManager.writeReason(
            reservation: updated,
            reason: QueueChangeReason.manualPromote,
          ));
          Loader.showSuccess("تم تقديم المريض في الطابور");
        },
        onDenied: (reason) => Loader.showError(reason),
      );
    } finally {
      _isProcessingStatus = false;
      update();
    }
  }

  // Fetch clinics
  Future<void> getClinicList() async {
    final currentUser = Get.find<UserSession>().user;

    if (currentUser == null || !currentUser.isAssistant) {
      return;
    }

    final assistant = currentUser.asAssistant;

    if (assistant == null) {
      return;
    }
    final clinicKey = assistant.clinicKey ?? "";

    final FirebaseFilter? filter = FirebaseFilter(
      orderBy: "key",
      equalTo: clinicKey,
    );

    ClinicService().getClinicsData(
      data: {},
      doctorKey: selectedDoctor?.uid ?? assistant.doctorKey ?? "",
      filrebaseFilter: filter ?? FirebaseFilter(),
      query: SQLiteQueryParams(),
      voidCallBack: (data) async {
        listClinic = data;
        Loader.dismiss();

        if (data.isNotEmpty) {
          clinicDropdownItems = ClinicAdapterUtil.convertClinicListToGeneric(
            data,
          );

          final clinics = data.whereType<ClinicModel>().toList();

          selectedClinic = clinics.firstWhere(
            (clinic) => clinic.key == clinicKey,
            orElse: () => clinics.first,
          );

          // 🔥 Sync newborn slot gap from clinic settings
          queueManager.newbornSlotGap =
              selectedClinic?.effectiveNewbornSlotGap ?? 2;

          await getShiftList();
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
          appointmentDate ??= DateFormat("dd-MM-yyyy").format(DateTime.now());

          await getReservations();

          update();
        },
      ),
      barrierDismissible: false, // 👈 مهم عشان يبقى mandatory
    );
  }

  Future<void> getShiftList() async {
    if (selectedClinic == null) return;

    final currentUser = Get.find<UserSession>().user;

    if (currentUser == null) {
      return;
    }

    final baseUser = currentUser.user;

    String? doctorKey;

    // ✅ Doctor
    if (baseUser is DoctorUser) {
      doctorKey = baseUser.uid;
    }
    // ✅ Assistant
    else if (baseUser is AssistantUser) {
      doctorKey = baseUser.doctorKey;
    }

    // ✅ center mode override
    doctorKey = isCenterMode ? selectedDoctor?.uid : doctorKey;

    final FirebaseFilter? filter = FirebaseFilter(
      orderBy: "clinicKey",
      equalTo: currentUser.clinicKey,
    );

    ShiftService().getShiftsData(
      data: filter ?? FirebaseFilter(),
      doctorKey: doctorKey ?? "",
      query: SQLiteQueryParams(),
      voidCallBack: (data) async {
        if (data.isNotEmpty) {
          shiftDropdownItems = ShiftModelAdapterUtil.convertShiftListToGeneric(
            data,
          );

          if (shiftDropdownItems!.length == 1) {
            selectedShift = shiftDropdownItems!.first;

            appointmentDate ??= DateFormat("dd-MM-yyyy").format(DateTime.now());

            await getReservations();
          } else {
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

  Future<void> changeReservationStatus({
    required ReservationModel reservation,
    required ReservationStatus newStatus,
    String? cancelReason,
  }) async {
    if (_isProcessingStatus) return;

    _isProcessingStatus = true;
    Loader.show();

    try {
      /// ✅ Optimistic UI
      reservation.status = newStatus.value;

      // /// ✅ PATH
      // final path =
      //     "doctors/${reservation.doctorUid}"
      //     "/reservations/${reservation.appointmentDateTime}"
      //     "/${reservation.key}";
      //
      // final ref = FirebaseDatabase.instance.ref(path);
      //
      // /// ✅ DATA
      // final updateData = {
      //   "status": newStatus.value,
      //   if (cancelReason != null) "cancelReason": cancelReason,
      // };
      //
      // /// 🔥 UPDATE DOCTOR (trigger function)
      // await ref.update(updateData);



      await ReservationService().updateReservationData(
        reservation: reservation,
        voidCallBack: (_) {
          getReservations();
        },
      );

      /// ✅ 🔥🔥🔥 UPDATE PATIENT COPY
      await PatientReservationService().updateReservationData(
        reservation: reservation.copyWith(status: newStatus.value),
        voidCallBack: (_) {},
      );

      /// ✅ UI Update
      _updateListInMemory(reservation);

      /// ✅ Side Effects
      _runSideEffectsInBackground(reservation, newStatus, cancelReason);

      Loader.showSuccess("تم تحديث الحالة إلى ${newStatus.label}");
    } catch (e, stack) {
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
      /// ✅ Serving pointer — single source of truth
      if (newStatus == ReservationStatus.inProgress) {
        // مريض جديد بدأ الكشف → اكتب الـ key
        unawaited(servingManager.setCurrentServing(reservation));
      } else if (newStatus == ReservationStatus.completed ||
          newStatus == ReservationStatus.missed ||
          newStatus.isCancelled) {
        // الكشف انتهى أو ألغي → امسح الـ pointer
        unawaited(servingManager.clearCurrentServing(reservation));
      }

      /// ✅ WhatsApp
      await WhatsAppStatusMessageService.sendStatusWhatsAppMessage(
        reservation: reservation,
        clinic: selectedClinic,
        newStatus: newStatus,
      );

      /// ✅ Queue
      if (newStatus == ReservationStatus.completed) {
        await WhatsAppSessionService.startPrescriptionSession(
          phone: reservation.patientPhone ?? "",
          reservationId: reservation.key ?? "",
        );

        await _handleQueueUpdate(snapshotReason: QueueChangeReason.windowShift);
      } else if (newStatus.isCancelled) {
        // Cancellation frees a slot — notify remaining patients their position changed.
        await _handleQueueUpdate(snapshotReason: QueueChangeReason.windowShift);
      }
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _handleQueueUpdate({
    QueueChangeReason? snapshotReason,
  }) async {
    final all = List<ReservationModel>.from(
      listReservations?.whereType<ReservationModel>().toList() ?? [],
    );

    await queueManager.notifyApprovedQueueUpdate(allReservations: all);

    // حفظ snapshot تلقائي عند كل تحديث كبير
    if (snapshotReason != null && all.isNotEmpty) {
      final doctorUid = all.first.doctorUid;
      final date = all.first.appointmentDateTime;
      if (doctorUid != null && date != null) {
        unawaited(snapshotManager.saveSnapshot(
          doctorUid: doctorUid,
          appointmentDate: date,
          allReservations: all,
          triggeredBy: snapshotReason,
        ));
      }
    }
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

  @override
  void onClose() {
    //  _reservationService.dispose();
    super.onClose();
  }
}

extension ReservationData on ReservationViewModel {
  void _listenToGlobalReservationEvents() {
    final service = ReservationService();

    service.onReservationAdded = (reservation) {
      if (!_belongsToCurrentFilters(reservation)) return;

      _updateListInMemory(reservation);
    };

    service.onReservationUpdated = (reservation) {
      if (!_belongsToCurrentFilters(reservation)) return;

      _updateListInMemory(reservation);
    };

    service.onReservationRemoved = (key) {
      completeDayReservations.removeWhere((e) => e?.key == key);

      final rebuilt = queueManager.buildFinalList(
        completeDayReservations.whereType<ReservationModel>().toList(),
      );

      listReservations = rebuilt;
      update();
    };
  }

  bool _belongsToCurrentFilters(ReservationModel r) {
    if (appointmentDate == null) return false;
    if (selectedShift == null) return false;
    if (selectedClinic == null) return false;

    final reservationDate = AppDateFormatter.toDash(r.appointmentDateTime);

    final screenDate = AppDateFormatter.toDash(appointmentDate);

    return reservationDate == screenDate &&
        r.shiftKey == selectedShift!.key &&
        r.clinicKey == selectedClinic!.key;
  }

  void _updateListInMemory(ReservationModel model) {
    final index = completeDayReservations.indexWhere(
      (e) => e?.key == model.key,
    );

    if (index != -1) {
      completeDayReservations[index] = model;
    } else {
      completeDayReservations.add(model);
    }

    listReservations = queueManager.buildFinalList(
      completeDayReservations.whereType<ReservationModel>().toList(),
    );

    _detectAndNotifyNewbornInsertion();

    update();
  }

  void _detectAndNotifyNewbornInsertion() {
    const activeStatuses = {
      'approved',
      'checked_in',
    };

    final currentCount = completeDayReservations
        .whereType<ReservationModel>()
        .where(
          (r) =>
              r.priorityLevel == 3 && activeStatuses.contains(r.status),
        )
        .length;

    if (currentCount > _activeNewbornCount) {
      unawaited(_handleNewbornInsertion());
    }
    _activeNewbornCount = currentCount;
  }

  Future<void> _handleNewbornInsertion() async {
    await _handleQueueUpdate(snapshotReason: QueueChangeReason.newbornInserted);

    const activeStatuses = {'approved', 'checked_in'};
    final nonNewbornActive = completeDayReservations
        .whereType<ReservationModel>()
        .where(
          (r) =>
              r.priorityLevel != 3 && activeStatuses.contains(r.status),
        )
        .toList();

    await queueReasonManager.writeBulkReason(
      reservations: nonNewbornActive,
      reason: QueueChangeReason.newbornInserted,
    );
  }

  Future<void> getReservations() async {
    final currentUser = Get.find<UserSession>().user;

    if (currentUser == null || !currentUser.isAssistant) {
      return;
    }

    final assistant = currentUser.asAssistant;

    if (assistant == null) {
      return;
    }

    final doctorKey = assistant.doctorKey;

    if (doctorKey == null ||
        doctorKey.isEmpty ||
        appointmentDate == null ||
        selectedShift == null) {
      return;
    }

    final normalizedDate = AppDateFormatter.toDash(appointmentDate);

    AppLogger.info("data in res", doctorKey + normalizedDate);

    // Restart Firebase listener for the current date (no-op if already on same date)
    unawaited(ReservationService().startListening(
      doctorKey: doctorKey,
      date: normalizedDate,
    ));

    try {
      /// 🔥 الترتيب مهم جدًا
      await fetchDailyReservations(normalizedDate);

      calculateStats(); // 🔥 هنا الصح

      await fetchFilteredReservations(normalizedDate);

      await loadDailyReport(normalizedDate);

      await getTotalTodayReservations();

      update();
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> fetchFilteredReservations(String normalizedDate) async {
    final query = filterManager.buildFilters(
      selectedClinic: selectedClinic,
      appointmentDate: normalizedDate,
      selectedShift: selectedShift,
      selectedTab: selectedTab,
    );

    final filtered = await queryManager.getReservations(query: query);

    listReservations = queueManager.buildFinalList(filtered);
  }

  Future<void> fetchDailyReservations(String normalizedDate) async {
    if (selectedShift == null) return;

    final all = await queryManager.getByFilters(
      appointmentDate: normalizedDate,
      shiftKey: selectedShift!.key,
      selectedClinic: selectedClinic,
    );

    _cachedReservations = all;

    completeDayReservations = all;
    update();
  }

  Future<void> loadDailyReport(String normalizedDate) async {
    if (selectedShift == null) return;

    completedForReport =
        _cachedReservations
            .where((e) => e.status == ReservationStatus.completed.value)
            .toList();
    AppLogger.info(
      "total list in repots",
      completedForReport.length.toString(),
    );
  }

  Future<int> getTotalTodayReservations() async {
    if (appointmentDate == null || selectedShift == null) {
      return 0;
    }

    return _cachedReservations.length;
  }

  Future<void> getLastReservationDateForPatient(LocalUser client) async {
    selectedPatientLastVisit = null;

    update();

    final reservation = await queryManager.getLastCompletedForPatient(
      client.uid!,
    );

    selectedPatientLastVisit =
        reservation == null
            ? "لا يوجد كشف سابق"
            : DatesUtilis.humanizeTimestamp(reservation.createdAt);

    update();
  }
}
