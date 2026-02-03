import 'dart:io';
import 'package:diwanclinic/Global/Enums/reservation_status_new.dart';
import 'package:diwanclinic/Presentation/screens/reservations/list/controllers_services/notification_service.dart';
import 'package:diwanclinic/Presentation/screens/reservations/list/controllers_services/prescription_upload_service.dart';
import 'package:intl/intl.dart';
import '../../../../../index/index_main.dart';

class ReservationViewModel extends GetxController {
  // 🔹 Realtime Sync
  bool showDailyReport = false;
  bool? fromUpdate;
  int selectedTab = 0; // 0 = ordinary, 1 = urgent
  int completedReservation = 0; // 0 = ordinary, 1 = urgent

  late final ReservationSyncService syncService;

  final notifier = ReservationNotificationService();
  final prescriptionService = PrescriptionUploadService();
  String? selectedPatientLastVisit;
  bool isSyncing = false;

  // 🔹 Reservation Data
  List<ReservationModel?>? listReservations;
  List<ReservationModel> completeDayReservations = [];

  List<ClinicModel?>? list_clinic;

  // 🔹 File Storage for Prescription Uploads
  File? firstImage;
  File? secondImage;

  // 🔹 Controllers
  final TextEditingController doseDaysController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // 🔹 Dropdown Filters
  List<GenericListModel>? clinicDropdownItems;
  List<GenericListModel>? shiftDropdownItems;

  ClinicModel? selectedClinic;
  GenericListModel? selectedShift;
  String? selectedType;
  ReservationNewStatus? selectedStatus;
  List<ReservationNewStatus>? selectedStatusesList; // NEW

  // 🔹 Date Filter
  num? create_at;
  String? appointment_date_time;

  bool _isInitialLoad = true;

  // 🔹 Filter list for types (NEW)
  final List<String> reservationTypeFilters = [
    "كشف جديد",
    "كشف مستعجل",
    "إعادة",
    "متابعة",
  ];

  @override
  Future<void> onInit() async {
    super.onInit();
    syncService = ReservationSyncService(controller: this);

    _setupDefaultDate();
    await getClinicList();
  }

  Future<List<ReservationModel>> fetchAllReservationsOfDay() async {
    // Build SQL WHERE clause
    String where = "";
    final whereArgs = <Object?>[];

    if (appointment_date_time != null) {
      where = "appointment_date_time = ?";
      whereArgs.add(appointment_date_time);
    }

    if (selectedClinic?.key != null) {
      if (where.isEmpty) {
        where = "clinic_key = ?";
      } else {
        where += " AND clinic_key = ?";
      }
      whereArgs.add(selectedClinic!.key);
    }

    final query = SQLiteQueryParams(
      is_filtered: where.isNotEmpty,
      where: where.isNotEmpty ? where : null,
      whereArgs: whereArgs,
      orderBy: "order_num ASC",
    );

    List<ReservationModel> result = [];

    await ReservationService().getReservationsData(
      date: appointment_date_time,
      data: FirebaseFilter(),
      query: query,
      voidCallBack: (list) {
        result = list.whereType<ReservationModel>().toList();
      },
    );

    // Save globally
    completeDayReservations = result;
    completedReservation = completeDayReservations
        .where((r) => r.status == "completed")
        .length;

    update(); // 🔥 update مرة واحدة فقط

    return result;
  }

  void getSyncReservations() {
    syncService.listen(
      selectedClinic: selectedClinic,
      appointmentDate: appointment_date_time,
      onAddLocal: (model) async {
        await addReservation(model, localOnly: true);
      },
      onUpdatedLocal: (model) async {
        await updateReservation(model, localOnly: true);
      },
      onReloadLocal: () {
        if (_isInitialLoad) return;

        if (!isSyncing) {
          getReservations();
        }
      },
    );
  }

  void _setupDefaultDate() {
    final now = DateTime.now();
    appointment_date_time = DateFormat('dd/MM/yyyy').format(now);
  }

  Future<void> getLastReservationDateForPatient(LocalUser client) async {
    selectedPatientLastVisit = null;
    update();

    try {
      final query = SQLiteQueryParams(
        is_filtered: false,
        where: "patient_key = ? AND status = ?",
        whereArgs: [client.key, ReservationStatus.completed.value],
        orderBy: "create_at DESC",
        limit: 1,
      );

      await ReservationService().getReservationsData(
        data: FirebaseFilter(),
        query: query,
        voidCallBack: (list) {
          if (list.isEmpty) {
            selectedPatientLastVisit = "لا يوجد كشف سابق";
          } else {
            final reservation = list.first as ReservationModel;
            selectedPatientLastVisit = _humanizeDate(reservation.createAt);
          }
          update();
        },
      );
    } catch (e) {
      selectedPatientLastVisit = "خطأ في تحميل آخر كشف";
      update();
    }
  }

  String _humanizeDate(int? timestamp) {
    if (timestamp == null) return "غير معروف";

    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return "منذ لحظات";
    if (diff.inMinutes < 60) return "منذ ${diff.inMinutes} دقيقة";
    if (diff.inHours < 24) return "منذ ${diff.inHours} ساعة";
    if (diff.inDays < 30) return "منذ ${diff.inDays} يوم";
    if (diff.inDays < 365) return "منذ ${diff.inDays ~/ 30} شهر";
    return "منذ ${diff.inDays ~/ 365} سنة";
  }

  // void getReservations({bool? is_filter}) {
  //   listReservations?.clear();
  //   // نبني شروط الفلترة
  //   String where = "";
  //   List<Object?> whereArgs = [];
  //
  //   // لو في clinic
  //   if (selectedClinic?.key != null) {
  //     where = "clinic_key = ?";
  //     whereArgs.add(selectedClinic!.key);
  //   }
  //
  //   // ─────────────────────────────────────────────
  //   // NEW STATUS FILTER LOGIC
  //   // ─────────────────────────────────────────────
  //
  //   // Case 1: Multi-status (الكل)
  //   if (selectedStatusesList != null && selectedStatusesList!.isNotEmpty) {
  //     final placeholders = List.filled(
  //       selectedStatusesList!.length,
  //       '?',
  //     ).join(',');
  //
  //     if (where.isEmpty) {
  //       where = "status IN ($placeholders)";
  //     } else {
  //       where += " AND status IN ($placeholders)";
  //     }
  //
  //     whereArgs.addAll(selectedStatusesList!.map((e) => e.value));
  //   }
  //   // Case 2: Single status selected
  //   else if (selectedStatus != null) {
  //     if (where.isEmpty) {
  //       where = "status = ?";
  //     } else {
  //       where += " AND status = ?";
  //     }
  //
  //     whereArgs.add(selectedStatus!.value);
  //   }
  //
  //   // status filter
  //   if (selectedType != null) {
  //     if (where.isEmpty) {
  //       where = "reservation_type = ?";
  //     } else {
  //       where += " AND reservation_type = ?";
  //     }
  //     whereArgs.add(selectedType);
  //   }
  //
  //   if (appointment_date_time != null) {
  //     if (where.isEmpty) {
  //       where = "appointment_date_time = ?";
  //     } else {
  //       where += " AND appointment_date_time = ?";
  //     }
  //     whereArgs.add(appointment_date_time);
  //   }
  //
  //   // String? assistant_key = LocalUser().getUserData().key;
  //   // // لو في appointment_date_time
  //   // if (assistant_key != null) {
  //   //   if (where.isEmpty) {
  //   //     where = "assistant_key = ?";
  //   //   } else {
  //   //     where += " AND assistant_key = ?";
  //   //   }
  //   //   whereArgs.add(assistant_key);
  //   // }
  //   final query = SQLiteQueryParams(
  //     is_filtered: is_filter ?? true,
  //     where: where.isNotEmpty ? where : null,
  //     whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
  //     orderBy: """
  //   CASE status
  //     WHEN 'in_progress' THEN 1
  //     WHEN 'pending' THEN 2
  //     WHEN 'approved' THEN 3
  //     ELSE 4
  //   END,
  //   order_num ASC
  // """,
  //   );
  //
  //   // نجيب الداتا من اللوكال
  //   ReservationService().getReservationsData(
  //     date: appointment_date_time,
  //     data: FirebaseFilter(), // irrelevant for local
  //
  //     query: query,
  //     voidCallBack: (list) {
  //       listReservations = list;
  //       // final policy = selectedClinic?.urgentPolicy ?? 1;
  //       // final fullList = list.whereType<ReservationModel>().toList();
  //       //
  //       // // 0️⃣ pending always on top — separate it
  //       // final pendingList = fullList
  //       //     .where((r) => r.status == ReservationStatus.pending.value)
  //       //     .toList();
  //       //
  //       // // 1️⃣ active (enter queue)
  //       // final activeList = fullList
  //       //     .where(
  //       //       (r) =>
  //       //           r.status != ReservationStatus.pending.value &&
  //       //           r.status != ReservationStatus.completed.value &&
  //       //           r.status != ReservationStatus.cancelledByUser.value &&
  //       //           r.status != ReservationStatus.cancelledByAssistant.value &&
  //       //           r.status != ReservationStatus.cancelledByDoctor.value,
  //       //     )
  //       //     .toList();
  //       //
  //       // // 2️⃣ completed/cancelled
  //       // final completedList = fullList
  //       //     .where(
  //       //       (r) =>
  //       //           r.status == ReservationStatus.completed.value ||
  //       //           r.status == ReservationStatus.cancelledByUser.value ||
  //       //           r.status == ReservationStatus.cancelledByAssistant.value ||
  //       //           r.status == ReservationStatus.cancelledByDoctor.value,
  //       //     )
  //       //     .toList();
  //       //
  //       // // 3️⃣ ترتيب active فقط
  //       // final activeQueue = buildFinalQueue(activeList, policy);
  //       //
  //       // // 4️⃣ Combine — pending always at top
  //       // listReservations = [
  //       //   ...pendingList, // ⬅️ TOP ALWAYS
  //       //   ...activeQueue,
  //       //   ...completedList,
  //       // ];
  //
  //       update();
  //     },
  //   );
  // }

  /// 🔧 Create WHERE filter for reservations query
  SQLiteQueryParams buildFilters({bool? is_filtered}) {
    String where = "";
    List<Object?> whereArgs = [];

    // Clinic
    if (selectedClinic?.key != null) {
      where = "clinic_key = ?";
      whereArgs.add(selectedClinic!.key);
    }

    // Date
    if (appointment_date_time != null) {
      if (where.isEmpty) {
        where = "appointment_date_time = ?";
      } else {
        where += " AND appointment_date_time = ?";
      }
      whereArgs.add(appointment_date_time);
    }

    // ⭐⭐⭐ TAB FILTER (ordinary / urgent) ⭐⭐⭐
    if (selectedTab == 1) {
      // 🔴 عاجل فقط
      if (where.isEmpty) {
        where = "reservation_type = ?";
      } else {
        where += " AND reservation_type = ?";
      }
      whereArgs.add("كشف مستعجل");
    }

    if (selectedTab == 0) {
      // 🟢 العادي فقط (استبعاد المستعجل)
      if (where.isEmpty) {
        where = "reservation_type != ?";
      } else {
        where += " AND reservation_type != ?";
      }
      whereArgs.add("كشف مستعجل");
    }

    return SQLiteQueryParams(
      is_filtered: is_filtered ?? true,
      where: where.isNotEmpty ? where : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: """
      CASE status 
        WHEN 'in_progress' THEN 1
        WHEN 'pending' THEN 2
        WHEN 'approved' THEN 3
        ELSE 4
      END,
      order_num ASC
    """,
    );
  }

  int aheadInQueue(ReservationModel r) {
    // جِب الانتظار فقط (pending + approved)
    final queue =
        listReservations
            ?.where(
              (e) =>
                  e?.status == ReservationStatus.pending.value ||
                  e?.status == ReservationStatus.approved.value,
            )
            .whereType<ReservationModel>()
            .toList() ??
        [];

    // ابحث عن هذا الحجز في queue فقط
    final index = queue.indexOf(r);

    if (index <= 0) return 0; // لو أول واحد → دورك الآن

    return index;
  }

  List<ReservationModel> reorderedQueue(List<ReservationModel?> list) {
    // clean null
    List<ReservationModel> clean = list.whereType<ReservationModel>().toList();

    // من يدخل في إعادة ترتيب؟
    List<ReservationModel> waiting = clean
        .where(
          (r) =>
              r.status == ReservationStatus.pending.value ||
              r.status == ReservationStatus.approved.value,
        )
        .toList();

    // ترتيبهم حسب رقم الحجز الأصلي
    waiting.sort(
      (a, b) => (a.order_num ?? 9999).compareTo(b.order_num ?? 9999),
    );

    // إعادة ترقيم الانتظار
    for (int i = 0; i < waiting.length; i++) {
      waiting[i] = waiting[i].copyWith(order_reserved: i + 1);
    }

    return waiting;
  }

  List<ReservationModel> buildFinalQueue(List<ReservationModel?> list) {
    final clean = list.whereType<ReservationModel>().toList();

    // ✨ Queue = فقط النشطين
    final queue = clean.where((r) {
      return r.status != ReservationStatus.completed.value &&
          r.status != ReservationStatus.cancelledByUser.value &&
          r.status != ReservationStatus.cancelledByAssistant.value &&
          r.status != ReservationStatus.cancelledByDoctor.value;
    }).toList();

    queue.sort((a, b) => (a.order_num ?? 9999).compareTo(b.order_num ?? 9999));

    for (int i = 0; i < queue.length; i++) {
      queue[i] = queue[i].copyWith(order_reserved: i + 1);
    }

    return queue;
  }

  /// 🔥 Fetch Reservations + Bulk Order and Merge + Sort
  Future<void> getReservations({bool? is_filter}) async {
    if (appointment_date_time == null) return;

    final query = buildFilters(is_filtered: is_filter);
    final date = appointment_date_time!;
    listReservations = [];

    await ReservationService().getReservationsData(
      date: date,
      data: FirebaseFilter(),
      query: query,
      voidCallBack: (list) {
        final all = list.whereType<ReservationModel>().toList();

        // 🔥 للتقارير
        completeDayReservations = all
            .where((r) => r.status == ReservationStatus.completed.value)
            .toList();

        final pending = all
            .where((r) => r.status == ReservationStatus.pending.value)
            .toList();

        final inProgress = all
            .where((r) => r.status == ReservationStatus.inProgress.value)
            .toList();

        final approved = all
            .where((r) => r.status == ReservationStatus.approved.value)
            .toList();

        final completed = all
            .where((r) => r.status == ReservationStatus.completed.value)
            .toList();

        final done = all
            .where(
              (r) =>
                  r.status == ReservationStatus.cancelledByAssistant.value ||
                  r.status == ReservationStatus.cancelledByUser.value ||
                  r.status == ReservationStatus.cancelledByDoctor.value,
            )
            .toList();

        // ✨ approved بس هي اللي تدخل queue
        final queue = reorderedQueue(approved);

        listReservations = [
          ...pending,
          ...inProgress,
          ...queue, // 👈 approved هنا
          ...completed, // 👈 completed لوحدها
          ...done, // completed + cancelled
        ];
        fetchAllReservationsOfDay();
        update();
      },
    );

    // var baseList =
    //     listReservations?.whereType<ReservationModel>().toList() ?? [];
    //
    // if (baseList.isEmpty) {
    //   update();
    //   return;
    // }

    // // 2) Fetch bulk order
    // Map<String, ReservationModel> orderMap = {};
    // await ReservationBulkService().getBulkData(
    //   date: date,
    //   voidCallBack: (map) => orderMap = map,
    // );
    //
    // // 3) Merge order fields
    // for (var r in baseList) {
    //   if (orderMap.containsKey(r.key)) {
    //     final o = orderMap[r.key]!;
    //     r.order_reserved = o.order_reserved;
    //     r.order_num = o.order_num;
    //   }
    // }
    // //  final urgentPolicy = selectedClinic?.urgentPolicy ?? 1;
    // // listReservations = _buildFinalQueue(baseList, urgentPolicy);
    // listReservations = baseList;
    // update();

    //  // fallback
    //  for (var r in baseList) {
    //    r.order_reserved ??= r.order_num;
    //  }
    //
    //  // 4) group
    //  final pendingList = baseList.where((r) => r.status == "pending").toList();
    //  final inProgressList = baseList
    //      .where((r) => r.status == "in_progress")
    //      .toList();
    //
    //  final queueList = baseList.where((r) => r.status == "approved").toList();
    //
    //  final doneList = baseList
    //      .where(
    //        (r) =>
    //            r.status == "completed" ||
    //            r.status == "cancelled_by_user" ||
    //            r.status == "cancelled_by_doctor" ||
    //            r.status == "cancelled_by_assistant",
    //      )
    //      .toList();
    //
    //
    //  // 5) reorder only approved
    //  final urgentPolicy = selectedClinic?.urgentPolicy ?? 1;
    //  final reorderedQueue = _buildFinalQueue(queueList, urgentPolicy);
    // // final reorderedQueue = queueList; // بدون أي ترتيب
    //
    //
    //  // 6) combine
    //  baseList = [
    //    ...pendingList, // always on top
    //    ...inProgressList, // after pending
    //    ...reorderedQueue, // real queue (approved only)
    //    ...doneList, // bottom
    //  ];
  }

  Future<int> getTotalTodayReservations() async {
    String? date = appointment_date_time;

    int count = 0;

    // cancelled values
    const cancelledStatuses = [
      "cancelled_by_user",
      "cancelled_by_assistant",
      "cancelled_by_doctor",
    ];

    // Create placeholders (?, ?, ?) for SQL
    final placeholders = List.filled(cancelledStatuses.length, '?').join(',');

    await ReservationService().getReservationsData(
      date: date,
      data: FirebaseFilter(),
      query: SQLiteQueryParams(
        is_filtered: true,
        // where: "appointment_date_time = ? AND status NOT IN ($placeholders)",
        // whereArgs: [date, ...cancelledStatuses],
        where: "appointment_date_time = ?",
        whereArgs: [date],
      ),
      voidCallBack: (list) {
        count = list.length;
      },
    );

    return count;
  }

  Future<List<ReservationModel>> getCompletedReservationsForReport() async {
    final String? date = appointment_date_time;

    List<ReservationModel> result = [];

    await ReservationService().getReservationsData(
      date: date,
      data: FirebaseFilter(),
      query: SQLiteQueryParams(
        is_filtered: true,
        where: "appointment_date_time = ? AND status = ?",
        whereArgs: [date, ReservationStatus.completed.value],
      ),
      voidCallBack: (list) {
        result = list.whereType<ReservationModel>().toList();
      },
    );

    return result;
  }

  Future<void> getClinicList() async {
    String clinicKey = LocalUser().getUserData().clinicKey ?? "";

    ClinicService().getClinicsData(
      data: {},
      filrebaseFilter: FirebaseFilter(),
      query: SQLiteQueryParams(
        is_filtered: clinicKey.isNotEmpty,
        where: clinicKey.isNotEmpty ? "key = ?" : null,
        whereArgs: clinicKey.isNotEmpty ? [clinicKey] : [],
      ),
      voidCallBack: (data) {
        list_clinic = data;
        Loader.dismiss();
        if (data.isNotEmpty) {
          clinicDropdownItems = ClinicAdapterUtil.convertClinicListToGeneric(
            data,
          );
          selectedClinic = data.first;
          getReservations();
          getSyncReservations();

          Future.delayed(const Duration(milliseconds: 300), () {
            _isInitialLoad = false;
          });
        }
        update();
      },
    );
  }

  Future<void> addReservation(
    ReservationModel reservation, {
    bool localOnly = false,
  }) async {
    await ReservationService().addReservationData(
      date: reservation.appointmentDateTime ?? "",
      reservation: reservation,
      localOnly: localOnly,
      voidCallBack: (_) {
        Loader.dismiss();
      },
    );
  }

  Future<void> updateReservation(
    ReservationModel reservation, {
    bool localOnly = false,
  }) async {
    if (isSyncing && !localOnly) return;

    await ReservationService().updateReservationData(
      date: reservation.appointmentDateTime ?? "",
      reservation: reservation,
      localOnly: localOnly,
      voidCallBack: (_) async {
        updatePatientReservation(reservation);

        // 🔥 لو الحجز اتقبل → امسح النوتيفيكيشن
        if (reservation.status == ReservationStatus.approved.value) {
          await NotificationCleanupService.removeReservationNotifications(
            reservationKey: reservation.key!,
          );
        }

        if (!localOnly) update();
      },
    );
  }

  Future<void> notifyApprovedQueueUpdate({
    required ReservationModel completedReservation,
  }) async {
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("🔔 notifyApprovedQueueUpdate START");
    debugPrint("✅ Completed reservation key: ${completedReservation.key}");
    debugPrint("📅 Date: ${completedReservation.appointmentDateTime}");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    // 🔹 جيب كل حجوزات اليوم
    await fetchAllReservationsOfDay();

    debugPrint(
      "📦 Total reservations today: ${completeDayReservations.length}",
    );

    // 🔹 approved فقط (الطابور)
    final approvedQueue = completeDayReservations
        .where((r) => r.status == ReservationStatus.approved.value)
        .toList();

    debugPrint("🟢 Approved queue count: ${approvedQueue.length}");

    // 🔹 ترتيبهم حسب رقم الحجز
    approvedQueue.sort(
      (a, b) => (a.order_num ?? 9999).compareTo(b.order_num ?? 9999),
    );

    debugPrint("📊 Approved queue after sorting:");
    for (int i = 0; i < approvedQueue.length; i++) {
      final r = approvedQueue[i];
      debugPrint(
        "   [$i] order_num=${r.order_num} | patient=${r.patientName} | uid=${r.patientUid}",
      );
    }

    // 🔔 ابعت نوتيفيكيشن لكل واحد
    for (int i = 0; i < approvedQueue.length; i++) {
      final r = approvedQueue[i];

      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("📨 Preparing notification");
      debugPrint("👤 Patient: ${r.patientName}");
      debugPrint("🆔 UID: ${r.patientUid}");
      debugPrint("📱 FCM Token: ${r.fcmToken_patient}");
      debugPrint("🔢 Order num: ${r.order_num}");
      debugPrint("📍 Queue index: $i");

      if (r.patientUid == null || r.fcmToken_patient == null) {
        debugPrint("⚠️ Skipped (missing uid or fcm token)");
        continue;
      }

      final ahead = i;

      final String body = ahead == 0
          ? "دورك الآن ✨ تفضل بالاستعداد للدخول"
          : "قبلك $ahead حالات، نرجو الاستعداد";

      debugPrint("✉️ Notification body: $body");

      await NotificationHandler().sendCustomNotification(
        toKey: r.patientUid!,
        toToken: r.fcmToken_patient!,
        title: "تحديث الدور",
        body: body,
        reservation: r,
        notificationType: "queue_update",
      );

      debugPrint("✅ Notification sent");
    }

    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("🔔 notifyApprovedQueueUpdate END");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  }

  void updatePatientReservation(ReservationModel reservation) {
    ReservationService().updatePatientReservationData(
      key: reservation.key ?? "",
      data: reservation,
      voidCallBack: (_) async {
        Loader.dismiss();
      },
    );
  }

  void deleteReservation(ReservationModel reservation) {
    ReservationService().deleteReservationData(
      date: reservation.appointmentDateTime ?? "",
      reservationKey: reservation.key ?? "",
      voidCallBack: (_) => getReservations(),
    );
  }

  void resetFilters() {
    selectedClinic = null;
    selectedShift = null;
    selectedStatus = null;
    create_at = null;
    _isInitialLoad = true;
    getReservations();
  }

  bool get hasActiveFilters =>
      selectedClinic != null ||
      selectedShift != null ||
      selectedStatus != null ||
      create_at != null;

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
    // if (selectedStatus != null) {
    //   filters.add({
    //     "label": "الحالة: ${selectedStatus!.label}",
    //     "onRemove": () {
    //       selectedStatus = null;
    //       getReservations();
    //       update();
    //     },
    //   });
    // }
    if (create_at != null) {
      final date = DateFormat(
        'dd/MM/yyyy',
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

  Future<void> openOrderConfirmationSheet({
    required BuildContext context,
    required ReservationModel reservation,
  }) async {
    if (reservation.patientKey == null) {
      Loader.showError("بيانات العميل غير متوفرة");
      return;
    }

    Loader.show();

    await AuthenticationService().getClientsLocalData(
      isFiltered: false, // 🔥 LOCAL ONLY
      query: SQLiteQueryParams(
        is_filtered: false,
        where: "key = ?", // 🔥 fetch only this patient
        whereArgs: [reservation.patientKey],
        limit: 1,
      ),
      voidCallBack: (List<LocalUser?> clients) {
        Loader.dismiss();

        if (clients.isEmpty) {
          Loader.showError("لم يتم العثور على بيانات العميل");
          return;
        }

        final user = clients.first!;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => OrderConfirmationSheet(
            reservation: reservation,
            user: user,
            onConfirmed: (updatedReservation) {
              updateReservation(updatedReservation);
            },
          ),
        );
      },
    );
  }

  // Future<void> openOrderConfirmationSheet({
  //   required BuildContext context,
  //   required ReservationModel reservation,
  // }) async {
  //   if (reservation.patientKey == null) {
  //     Loader.showError("بيانات المريض غير متوفرة");
  //     return;
  //   }
  //
  //   AuthenticationService().getSingleClientsData(
  //     filrebaseFilter: FirebaseFilter(
  //       equalTo: reservation.patientKey!,
  //       orderBy: "key",
  //     ),
  //     voidCallBack: (user) {
  //       Loader.dismiss();
  //
  //       if (user == null) {
  //         Loader.showError("لم يتم العثور على بيانات المريض");
  //         return;
  //       }
  //
  //       showModalBottomSheet(
  //         context: context,
  //         isScrollControlled: true,
  //         backgroundColor: AppColors.white,
  //         shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  //         ),
  //         builder: (_) => OrderConfirmationSheet(
  //           reservation: reservation,
  //           user: user,
  //           onConfirmed: (updatedReservation) {
  //             updateReservation(updatedReservation);
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  /// Returns how many reservations are ahead of the given reservation
  /// considering only reservations for the same appointment_date_time and clinic (today).
  /// If result <= 0 then returns 0 (means it's your turn or already passed).
}

class NotificationCleanupService {
  static Future<void> removeReservationNotifications({
    required String reservationKey,
  }) async {
    final service = ParentNotificationService();

    await service.getNotificationsData(
      data: FirebaseFilter(orderBy: "reservation_key", equalTo: reservationKey),
      query: SQLiteQueryParams(),
      voidCallBack: (list) async {
        for (final notif in list) {
          if (notif?.key == null) continue;

          await service.deleteNotificationData(
            notificationKey: notif!.key!,
            voidCallBack: (_) {
              Loader.dismiss();
              NotificationController controller = initController(
                () => NotificationController(),
              );
              //  controller.getNotifications();
              controller.update();
            },
          );
        }
      },
    );
  }
}
