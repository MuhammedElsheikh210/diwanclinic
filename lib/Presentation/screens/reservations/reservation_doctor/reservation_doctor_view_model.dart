import 'dart:async';
import 'dart:io';
import 'package:diwanclinic/Presentation/screens/reservations/reservation_doctor/reservatiob_sync_doctor.dart';
import 'package:intl/intl.dart';
import '../../../../../index/index_main.dart';

class ReservationDoctorViewModel extends GetxController {
  // ─────────────────────────────────────────────
  // 🔹 Realtime Sync
  // ─────────────────────────────────────────────
  late final ReservationDocTorSyncService syncService;
  bool isSyncing = false;
  bool showDailyReport = false;

  final notifier = ReservationNotificationService();
  final prescriptionService = PrescriptionUploadService();

  bool get hasActiveFilters =>
      selectedClinic != null ||
      selectedShift != null ||
      selectedStatus != null ||
      selectedStatusesList != null && selectedStatusesList!.isNotEmpty ||
      selectedType != null ||
      create_at != null;

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

  final List<String> reservationTypeFilters = [
    "كشف جديد",
    "كشف مستعجل",
    "إعادة",
    "متابعة",
  ];

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
  // INIT
  // ─────────────────────────────────────────────
  @override
  Future<void> onInit() async {
    super.onInit();

    syncService = ReservationDocTorSyncService(controller: this);

    _setupDefaultDate();
    await getClinicList();
  }

  @override
  void onClose() {
    syncService.dispose();
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
                .map(
                  (s) => GenericListModel(
                    key: s.key,
                    name: "${s.name ?? ""} (${s.dayOfWeek ?? ""})",
                  ),
                )
                .toList();

        update();
        completer.complete();
      },
    );

    return completer.future;
  }

  // ─────────────────────────────────────────────
  // DEFAULT DATE
  // ─────────────────────────────────────────────
  void _setupDefaultDate() {
    final now = DateTime.now();
    appointment_date_time = DateFormat('dd-MM-yyyy').format(now);
  }

  // ─────────────────────────────────────────────
  // DAY STATS
  // ─────────────────────────────────────────────
  void loadDayStats() {
    ReservationService().getReservationsData(
      query: SQLiteQueryParams(
        is_filtered: true,
        where: "appointment_date_time = ? AND doctor_key = ?",
        whereArgs: [appointment_date_time, _doctorKey],
      ),
      voidCallBack: (list) {
        dayReservations = list.whereType<ReservationModel>().toList();
        update();
      },
    );
  }

  // ─────────────────────────────────────────────
  // 🔁 SYNC (Firebase → SQLite → UI)
  // ─────────────────────────────────────────────
  void getSyncReservations() {
    syncService.listen(
      selectedClinic: selectedClinic,
      appointmentDate: appointment_date_time,
      // ⚠️ SAME FORMAT dd/MM/yyyy
      onAddLocal: (model) async {
        isSyncing = true;
        await addReservation(model, localOnly: true);
        isSyncing = false;
      },
      onUpdatedLocal: (model) async {
        isSyncing = true;
        await updateReservation(model, localOnly: true);
        isSyncing = false;
      },
      onReloadLocal: () {
        if (!isSyncing) {
          getReservations();
        }
      },
    );
  }

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
  // ADD / UPDATE LOCAL
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
  // FETCH RESERVATIONS (SOURCE OF TRUTH)
  // ─────────────────────────────────────────────
  void getReservations({bool? is_filter}) {
    if (appointment_date_time == null) return;

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
      where += " AND doctor_key = ?";
      whereArgs.add(_doctorKey);
    }

    final query = SQLiteQueryParams(
      is_filtered: false,
      where: where,
      whereArgs: whereArgs,
      orderBy: "order_num ASC",
    );

    ReservationService().getReservationsData(
      query: query,
      voidCallBack: (list) {
        Loader.dismiss();
        final all = list.whereType<ReservationModel>().toList();

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

        loadDayStats();
        update();
      },
    );
  }

  // ─────────────────────────────────────────────
  // QUEUE HELPERS
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

  int aheadInQueue(ReservationModel r) {
    if (listReservations == null) return 0;
    final index = listReservations!.indexOf(r);
    return index <= 0 ? 0 : index;
  }

  // ─────────────────────────────────────────────
  // CLINICS
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

            // 🔥 لو عنده شيفت واحد
            if (shiftDropdownItems != null && shiftDropdownItems!.length == 1) {
              selectedShift = shiftDropdownItems!.first;
            }
          }

          getSyncReservations();
          getReservations();
        }
        update();
      },
    );
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────
  void deleteReservation(ReservationModel reservation) {
    ReservationService().deleteReservationData(
      reservationKey: reservation.key ?? "",
      voidCallBack: (_) => getReservations(),
    );
  }
}
