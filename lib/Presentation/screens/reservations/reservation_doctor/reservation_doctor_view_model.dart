import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';

import '../../../../../index/index_main.dart';

class ReservationDoctorViewModel extends GetxController {
  // ─────────────────────────────────────────────
  // 🔹 Services
  // ─────────────────────────────────────────────

  final PrescriptionUploadService prescriptionService =
      PrescriptionUploadService();

  // ─────────────────────────────────────────────
  // 🔹 UI State
  // ─────────────────────────────────────────────
  bool isSyncing = false;
  bool showDailyReport = false;

  // ─────────────────────────────────────────────
  // 🔹 Reservation Data
  // ─────────────────────────────────────────────
  List<ReservationModel?>? listReservations;

  List<ReservationModel> dayReservations = [];

  List<ClinicModel?>? list_clinic;

  // ─────────────────────────────────────────────
  // 🔹 File Storage
  // ─────────────────────────────────────────────
  File? firstImage;
  File? secondImage;

  // ─────────────────────────────────────────────
  // 🔹 Controllers
  // ─────────────────────────────────────────────
  final TextEditingController doseDaysController = TextEditingController();

  final TextEditingController notesController = TextEditingController();

  // ─────────────────────────────────────────────
  // 🔹 Filters
  // ─────────────────────────────────────────────
  List<GenericListModel>? clinicDropdownItems;
  List<GenericListModel>? shiftDropdownItems;

  ClinicModel? selectedClinic;
  GenericListModel? selectedShift;

  String? selectedType;

  ReservationNewStatus? selectedStatus;
  List<ReservationNewStatus>? selectedStatusesList;

  num? create_at;

  String? appointment_date_time;

  // ─────────────────────────────────────────────
  // 🔹 Helpers
  // ─────────────────────────────────────────────
  String? get _doctorKey {
    final user = Get.find<UserSession>().user;

    return user?.uid ?? user?.doctorKey;
  }

  bool get hasActiveFilters =>
      selectedClinic != null ||
      selectedShift != null ||
      selectedStatus != null ||
      selectedStatusesList != null && selectedStatusesList!.isNotEmpty ||
      selectedType != null ||
      create_at != null;

  final List<String> reservationTypeFilters = [
    "كشف جديد",
    "كشف مستعجل",
    "إعادة",
    "متابعة",
  ];

  // ─────────────────────────────────────────────
  // 🔹 Stats
  // ─────────────────────────────────────────────
  int get completedCount =>
      dayReservations
          .where((r) => r.status == ReservationStatus.completed.value)
          .length;

  int get pendingCount =>
      dayReservations
          .where(
            (r) =>
                r.status == ReservationStatus.approved.value ||
                r.status == ReservationStatus.inProgress.value,
          )
          .length;

  int get totalCount => completedCount + pendingCount;

  // ─────────────────────────────────────────────
  // 🔹 INIT
  // ─────────────────────────────────────────────
  @override
  Future<void> onInit() async {
    super.onInit();

    _setupDefaultDate();

    await getClinicList();

    _listenToGlobalReservationEvents();
  }

  void showMandatoryShiftDialog() {
    if (shiftDropdownItems == null || shiftDropdownItems!.isEmpty) {
      return;
    }

    Get.dialog(
      ShiftSelectionDialog(
        shifts: shiftDropdownItems!,
        initialSelected: selectedShift,

        onSelect: (shift) async {
          selectedShift = shift;

          appointment_date_time ??= DateFormat(
            "dd-MM-yyyy",
          ).format(DateTime.now());

          getReservations();

          update();
        },
      ),

      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
   // _reservationService.dispose();

    super.onClose();
  }

  // ─────────────────────────────────────────────
  // 🔹 Load Shifts By Clinic
  // ─────────────────────────────────────────────
  Future<void> loadShiftsForClinic(String clinicKey) async {
    final completer = Completer<void>();

    ShiftService().getShiftssFromPatientData(
      data: {},
      doctorKey: _doctorKey ?? "",
      voidCallBack: (data) {
        final filtered =
            data
                .whereType<ShiftModel>()
                .where((s) => s.clinicKey == clinicKey)
                .toList();

        shiftDropdownItems =
            filtered
                .map((s) => GenericListModel(key: s.key, name: s.name ?? ""))
                .toList();

        update();

        completer.complete();
      },
    );

    return completer.future;
  }

  // ─────────────────────────────────────────────
  // 🔹 Default Date
  // ─────────────────────────────────────────────
  void _setupDefaultDate() {
    final now = DateTime.now();

    appointment_date_time = DateFormat('dd-MM-yyyy').format(now);
  }

  // ─────────────────────────────────────────────
  // 🔹 Day Stats
  // ─────────────────────────────────────────────
  void loadDayStats() {
    if (selectedShift == null) return;

    String where =
        "appointment_date_time = ? "
        "AND doctor_uid = ? "
        "AND shift_key = ?";

    final whereArgs = [
      appointment_date_time,
      _doctorKey,
      selectedShift!.key,
    ];

    // ✅ optional clinic filter
    if (selectedClinic?.key != null) {
      where += " AND clinic_key = ?";
      whereArgs.add(selectedClinic!.key);
    }

    ReservationService().getReservationsData(
      query: SQLiteQueryParams(
        is_filtered: true,
        where: where,
        whereArgs: whereArgs,
      ),
      voidCallBack: (list) {
        dayReservations = list.whereType<ReservationModel>().toList();

        update();
      },
    );
  }
  // ─────────────────────────────────────────────
  // 🔹 Active Filters
  // ─────────────────────────────────────────────
  List<Map<String, dynamic>> get activeFilters {
    final filters = <Map<String, dynamic>>[];

    if (selectedClinic != null) {
      filters.add({
        "label": "العيادة: ${selectedClinic?.title ?? ''}",
        "onRemove": () {
          selectedClinic = null;
          getReservations();
          update();
        },
      });
    }

    if (selectedShift != null) {
      filters.add({
        "label": "الوردية: ${selectedShift?.name ?? ''}",
        "onRemove": () {
          selectedShift = null;
          getReservations();
          update();
        },
      });
    }

    if (selectedStatus != null) {
      filters.add({
        "label": "الحالة: ${selectedStatus!.label}",
        "onRemove": () {
          selectedStatus = null;
          getReservations();
          update();
        },
      });
    }

    if (selectedStatusesList != null && selectedStatusesList!.isNotEmpty) {
      filters.add({
        "label":
            "الحالات: ${selectedStatusesList!.map((e) => e.label).join('، ')}",
        "onRemove": () {
          selectedStatusesList = null;
          getReservations();
          update();
        },
      });
    }

    if (selectedType != null) {
      filters.add({
        "label": "النوع: $selectedType",
        "onRemove": () {
          selectedType = null;
          getReservations();
          update();
        },
      });
    }

    if (create_at != null) {
      final date = DateFormat(
        'dd-MM-yyyy',
      ).format(DateTime.fromMillisecondsSinceEpoch(create_at!.toInt()));

      filters.add({
        "label": "التاريخ: $date",
        "onRemove": () {
          create_at = null;
          getReservations();
          update();
        },
      });
    }

    return filters;
  }

  // ─────────────────────────────────────────────
  // 🔹 Add / Update Local
  // ─────────────────────────────────────────────
  Future<void> addReservation(
    ReservationModel reservation, {
    bool localOnly = false,
  }) async {
    await ReservationService().addReservationData(
      reservation: reservation,
      voidCallBack: (_) {},
    );
  }

  Future<void> updateReservation(
    ReservationModel reservation, {
    bool localOnly = false,
  }) async {
    if (isSyncing && !localOnly) return;

    await ReservationService().updateReservationData(
      reservation: reservation,
      voidCallBack: (_) {},
    );
  }

  // ─────────────────────────────────────────────
  // 🔹 Fetch Reservations
  // ─────────────────────────────────────────────
  void getReservations({bool? is_filter}) async {
    AppLogger.info("DOCTOR_DEBUG", "==============================");

    AppLogger.info(
      "DOCTOR_DEBUG",
      "appointment_date_time => $appointment_date_time",
    );

    AppLogger.info("DOCTOR_DEBUG", "selectedShift => ${selectedShift?.key}");

    AppLogger.info("DOCTOR_DEBUG", "selectedClinic => ${selectedClinic?.key}");

    AppLogger.info("DOCTOR_DEBUG", "doctorKey => $_doctorKey");

    if (appointment_date_time == null) {
      AppLogger.error("DOCTOR_DEBUG", "❌ appointment_date_time NULL");
      return;
    }

    if (selectedShift == null) {
      AppLogger.error("DOCTOR_DEBUG", "❌ selectedShift NULL");
      return;
    }

    listReservations = [];

    String where = "";

    final whereArgs = <Object?>[];

    if (selectedClinic?.key != null) {
      where = "clinic_key = ?";
      whereArgs.add(selectedClinic!.key);
    }

    if (selectedShift?.key != null) {
      where += where.isEmpty ? "" : " AND ";
      where += "shift_key = ?";
      whereArgs.add(selectedShift!.key);
    }

    if (selectedType != null) {
      where += where.isEmpty ? "" : " AND ";
      where += "reservation_type = ?";
      whereArgs.add(selectedType);
    }

    where += where.isEmpty ? "" : " AND ";
    where += "appointment_date_time = ?";

    whereArgs.add(appointment_date_time);

    if (_doctorKey != null && _doctorKey!.isNotEmpty) {
      where += " AND doctor_uid = ?";
      whereArgs.add(_doctorKey);
    }

    AppLogger.info("DOCTOR_DEBUG", "FINAL WHERE => $where");

    AppLogger.info("DOCTOR_DEBUG", "WHERE ARGS => $whereArgs");

    final query = SQLiteQueryParams(
      is_filtered: false,
      where: where,
      whereArgs: whereArgs,
      orderBy: "order_num ASC",
    );

    ReservationService().getReservationsData(
      query: query,
      voidCallBack: (list) {
        AppLogger.info("DOCTOR_DEBUG", "SQL RESULT COUNT => ${list.length}");

        for (final item in list.take(10)) {
          final r = item as ReservationModel;

          AppLogger.info("DOCTOR_DEBUG", """
PATIENT => ${r.patientName}
DATE => ${r.appointmentDateTime}
SHIFT => ${r.shiftKey}
CLINIC => ${r.clinicKey}
STATUS => ${r.status}
ORDER => ${r.orderNum}
""");
        }

        Loader.dismiss();

        final all =
            list
                .whereType<ReservationModel>()
                .where((r) => r.status != ReservationStatus.pending.value)
                .toList();
        AppLogger.info("DOCTOR_DEBUG", "AFTER CAST => ${all.length}");

        final inProgress =
            all
                .where((r) => r.status == ReservationStatus.inProgress.value)
                .toList();

        final approved =
            all
                .where((r) => r.status == ReservationStatus.approved.value)
                .toList();

        final completed =
            all
                .where((r) => r.status == ReservationStatus.completed.value)
                .toList();

        final cancelled =
            all
                .where(
                  (r) =>
                      r.status == ReservationStatus.cancelledByUser.value ||
                      r.status ==
                          ReservationStatus.cancelledByAssistant.value ||
                      r.status == ReservationStatus.cancelledByDoctor.value,
                )
                .toList();

        final queue = reorderedQueue(approved);

        listReservations = [
          ...inProgress,
          ...queue,
          ...completed,
          ...cancelled,
        ];

        AppLogger.info(
          "DOCTOR_DEBUG",
          "FINAL UI LIST => ${listReservations?.length}",
        );

        loadDayStats();

        update();
      },
    );
  }

  // ─────────────────────────────────────────────
  // 🔹 Queue Helpers
  // ─────────────────────────────────────────────
  List<ReservationModel> reorderedQueue(List<ReservationModel> list) {
    final waiting =
        list
            .where((r) => r.status == ReservationStatus.approved.value)
            .toList();

    waiting.sort((a, b) => (a.orderNum ?? 9999).compareTo(b.orderNum ?? 9999));

    for (int i = 0; i < waiting.length; i++) {
      waiting[i] = waiting[i].copyWith(orderReserved: i + 1);
    }

    return waiting;
  }

  void _rebuildReservationsList() {
    final all = List<ReservationModel>.from(dayReservations);

    final inProgress =
    all
        .where(
          (r) => r.status == ReservationStatus.inProgress.value,
    )
        .toList();

    final approved =
    all
        .where(
          (r) => r.status == ReservationStatus.approved.value,
    )
        .toList();

    final completed =
    all
        .where(
          (r) => r.status == ReservationStatus.completed.value,
    )
        .toList();

    final cancelled =
    all
        .where(
          (r) =>
      r.status == ReservationStatus.cancelledByUser.value ||
          r.status == ReservationStatus.cancelledByAssistant.value ||
          r.status == ReservationStatus.cancelledByDoctor.value,
    )
        .toList();

    final queue = reorderedQueue(approved);

    listReservations = [
      ...inProgress,
      ...queue,
      ...completed,
      ...cancelled,
    ];

    update();
  }

  int aheadInQueue(ReservationModel r) {
    if (listReservations == null) {
      return 0;
    }

    final index = listReservations!.indexOf(r);

    return index <= 0 ? 0 : index;
  }

  // ─────────────────────────────────────────────
  // 🔹 Clinics
  // ─────────────────────────────────────────────
  Future<void> getClinicList() async {
    final doctorKey = _doctorKey ?? "";

    ClinicService().getClinicsData(
      data: {},
      doctorKey: doctorKey,
      filrebaseFilter: FirebaseFilter(
        orderBy: "doctor_key",
        equalTo: doctorKey,
      ),
      query: SQLiteQueryParams(
        is_filtered: doctorKey.isNotEmpty,
        where: "doctor_key = ?",
        whereArgs: [doctorKey],
      ),
      voidCallBack: (data) async {
        list_clinic = data;

        if (data.isNotEmpty) {
          clinicDropdownItems = ClinicAdapterUtil.convertClinicListToGeneric(
            data,
          );

          // 🔥 لو عنده عيادة واحدة
          if (data.length == 1) {
            selectedClinic = data.first;

            await loadShiftsForClinic(selectedClinic!.key!);

            // 🔥 لو شيفت واحد اختاره تلقائي
            if (shiftDropdownItems != null && shiftDropdownItems!.length == 1) {
              selectedShift = shiftDropdownItems!.first;

              getReservations();
            }
            // 🔥 لو أكتر من شيفت لازم يختار
            else if (shiftDropdownItems != null &&
                shiftDropdownItems!.isNotEmpty) {
              Future.microtask(() {
                showMandatoryShiftDialog();
              });
            }
          }
        }

        update();
      },
    );
  }

  // ─────────────────────────────────────────────
  // 🔹 Delete
  // ─────────────────────────────────────────────
  void deleteReservation(ReservationModel reservation) {
    ReservationService().deleteReservationData(
      reservationKey: reservation.key ?? "",
      voidCallBack: (_) => getReservations(),
    );
  }
}

extension ReservationDoctorData on ReservationDoctorViewModel {
  void _listenToGlobalReservationEvents() {
    final service = ReservationService();

    service.onReservationAdded = (reservation) async {
      if (!_belongsToCurrentFilters(reservation)) {
        return;
      }

      _updateListInMemory(reservation);
    //  await Future.microtask(() => getReservations());

    };

    service.onReservationUpdated = (reservation) async {
      if (!_belongsToCurrentFilters(reservation)) {
        return;
      }
      _updateListInMemory(reservation);

    //  await Future.microtask(() => getReservations());
    };

    service.onReservationRemoved = (key) {
      dayReservations.removeWhere((e) => e.key == key);

      _rebuildReservationsList();
    };
  }

  bool _belongsToCurrentFilters(ReservationModel r) {
    if (appointment_date_time == null) {
      return false;
    }

    if (selectedShift == null) {
      return false;
    }

    if (selectedClinic == null) {
      return false;
    }

    final reservationDate = AppDateFormatter.toDash(r.appointmentDateTime);

    final screenDate = AppDateFormatter.toDash(appointment_date_time);

    return reservationDate == screenDate &&
        r.shiftKey == selectedShift!.key &&
        r.clinicKey == selectedClinic!.key;
  }

  void _updateListInMemory(ReservationModel model) {
    if (dayReservations.isEmpty) {
      getReservations();
      return;
    }

    final index = dayReservations.indexWhere(
          (e) => e.key == model.key,
    );

    if (index != -1) {
      dayReservations[index] = model;
    } else {
      dayReservations.add(model);
    }

    _rebuildReservationsList();
  }
}
