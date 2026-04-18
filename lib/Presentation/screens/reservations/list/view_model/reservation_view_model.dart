import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import '../../../../../../index/index_main.dart';

class ReservationViewModel extends GetxController {
  // Managers
  late final ReservationQueueManager queueManager;
  late final ReservationFilterManager filterManager;
  late final ReservationActionManager actionManager;
  late final ReservationQueryManager queryManager;
  bool hideShiftSelector = false;
  bool _isProcessingStatus = false;
  List<ReservationModel> _cachedReservations = [];

  final ReservationService _reservationService = ReservationService();

  // Services
  final PrescriptionUploadService prescriptionService =
      PrescriptionUploadService();

  // UI State
  bool showDailyReport = false;
  bool? fromUpdate;
  bool isSyncing = false;

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
  List<LocalUser?>? centerDoctors;
  LocalUser? selectedDoctor;
  bool isLoadingDoctors = false;

  bool get isCenterMode => false;

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
  }

  // Fetch clinics
  Future<void> getClinicList() async {
    final currentUser = Get.find<UserSession>().user;

    if (currentUser == null || !currentUser.isAssistant) {
      debugPrint("❌ Current user is not assistant");
      return;
    }

    final assistant = currentUser.asAssistant;

    if (assistant == null) {
      debugPrint("❌ Failed to cast to AssistantUser");
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
      debugPrint("❌ User not found in session");
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
        if (data != null && data.isNotEmpty) {
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
      fromUpdate = true;

      /// ✅ PATH
      final path =
          "doctors/${reservation.doctorUid}"
          "/reservations/${reservation.appointmentDateTime}"
          "/${reservation.key}";

      final ref = FirebaseDatabase.instance.ref(path);

      /// ✅ DATA
      final updateData = {
        "status": newStatus.value,
        if (cancelReason != null) "cancelReason": cancelReason,
      };

      /// 🔥 UPDATE DOCTOR (trigger function)
      await ref.update(updateData);

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
      debugPrint("❌ changeReservationStatus ERROR: $e");
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
      // ❌ لا notification
      // ❌ لا WhatsApp

      await WhatsAppStatusMessageService.sendStatusWhatsAppMessage(
        reservation: reservation,
        clinic: selectedClinic,
        newStatus: newStatus,
      );

      // ✅ Queue فقط
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
    try {
      await NotificationHandler().sendStatusNotification(
        newStatus: newStatus,
        reservation: reservation,
        toToken: reservation.patientFcm!,
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
    } catch (e, s) {
      debugPrint("❌ Notification Error: $e");
      debugPrintStack(stackTrace: s);
    }

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

  @override
  void onClose() {
    _reservationService.dispose();
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

    service.onReservationUpdated = (reservation) async {
      if (!_belongsToCurrentFilters(reservation)) return;

      await getReservations();
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

    final reservationDate = AppDateFormatter.normalize(r.appointmentDateTime);

    final screenDate = AppDateFormatter.normalize(appointmentDate);

    return reservationDate == screenDate &&
        r.shiftKey == selectedShift!.key &&
        r.clinicKey == selectedClinic!.key;
  }

  void _updateListInMemory(ReservationModel model) {
    if (fromUpdate == true) {
      fromUpdate = false;
      return;
    }

    /// 🔥 لو القائمة فاضية → اعمل reload
    if (completeDayReservations.isEmpty) {
      getReservations();
      return;
    }

    final index = completeDayReservations.indexWhere(
      (e) => e?.key == model.key,
    );

    if (index != -1) {
      completeDayReservations[index] = model;
    } else {
      completeDayReservations.add(model);
    }

    listReservations = List.from(completeDayReservations);

    update();
  }

  Future<void> getReservations() async {
    final currentUser = Get.find<UserSession>().user;

    if (currentUser == null || !currentUser.isAssistant) {
      debugPrint("❌ Current user is not assistant");
      return;
    }

    final assistant = currentUser.asAssistant;

    if (assistant == null) {
      debugPrint("❌ Failed to cast to AssistantUser");
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

    try {
      /// 🔥 الترتيب مهم جدًا
      await fetchDailyReservations(normalizedDate);

      calculateStats(); // 🔥 هنا الصح

      await fetchFilteredReservations(normalizedDate);

      await loadDailyReport(normalizedDate);

      await getTotalTodayReservations();

      update();
    } catch (e, stack) {
      debugPrint("❌ getReservations ERROR: $e");
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
