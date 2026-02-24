import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import '../../../../../index/index_main.dart';

class ReservationPatientViewModel extends GetxController {
  // 🔹 Realtime Sync
  bool showDailyReport = false;
  bool? fromUpdate;
  final syncService = ReservationSyncService();
  final notifier = ReservationNotificationService();
  final prescriptionService = PrescriptionUploadService();
  int legacyQueueCount = 0;

  // 🔹 Reservation Data
  List<ReservationModel?>? listReservations;
  List<ReservationModel?>? listReservations_Home;
  List<ReservationModel?>? listReservations_count;
  List<ClinicModel?>? list_clinic;

  // 🔹 File Storage for Prescription Uploads
  File? firstImage;
  File? secondImage;
  int? totalCompleted;

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

  List<ReservationModel?> get sortedReservations {
    final list = List<ReservationModel?>.from(listReservations ?? []);

    list.sort((a, b) {
      final int timeA = a?.createAt ?? 0;
      final int timeB = b?.createAt ?? 0;
      return timeB.compareTo(timeA); // NEW -> OLD
    });

    return list;
  }

  List<String> get _finalStatuses => [
    ReservationStatus.completed.value,
    ReservationStatus.cancelledByUser.value,
    ReservationStatus.cancelledByAssistant.value,
    ReservationStatus.cancelledByDoctor.value,
  ];

  List<ReservationModel?> get completedReservations {
    return sortedReservations
        .where((r) => _finalStatuses.contains(r?.status))
        .toList();
  }

  List<ReservationModel?> get otherReservations {
    return sortedReservations
        .where((r) => !_finalStatuses.contains(r?.status))
        .toList();
  }

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
    getReservations();
    getSyncReservations(initLocalData: true);
  }

  Future<void> loadLegacyQueueCount({
    required String doctorUid,
    required String clinicKey,
    required String date,
  }) async {
    legacyQueueCount = 0;

    await LegacyQueueService().getLegacyQueueByDateData(
      date: date, // dd-MM-yyyy
      isPatient: true,
      doctorUid: doctorUid,
      voidCallBack: (data) {
        for (final item in data) {
          if (item == null) continue;

          if (item.clinic_key == clinicKey) {
            legacyQueueCount = item.value ?? 0;
            break;
          }
        }
      },
    );

    update();
  }

  Future<void> syncMissingFcmTokenForMyReservations() async {
    final user = LocalUser().getUserData();
    final String? myUid = user.uid;
    final String? myToken = user.fcmToken;

    if (myUid == null || myUid.isEmpty) {
      debugPrint("❌ [FCM SYNC] No user uid");
      return;
    }

    if (myToken == null || myToken.isEmpty) {
      debugPrint("❌ [FCM SYNC] No FCM token on device");
      return;
    }

    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("🔄 [FCM SYNC] Start syncing missing tokens");
    debugPrint("👤 UID: $myUid");
    debugPrint("📱 Token: $myToken");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    final reservations =
        listReservations
            ?.whereType<ReservationModel>()
            .where(
              (r) =>
                  r.patientUid == myUid &&
                  (r.fcmToken_patient == null || r.fcmToken_patient!.isEmpty),
            )
            .toList() ??
        [];

    if (reservations.isEmpty) {
      debugPrint("ℹ️ [FCM SYNC] No reservations need update");
      return;
    }

    debugPrint("🧩 [FCM SYNC] Reservations to update: ${reservations.length}");

    for (final r in reservations) {
      final updated = r.copyWith(fcmTokenPatient: myToken);

      debugPrint("🔁 Updating reservation ${r.key} | order=${r.order_num}");

      // 1️⃣ Update main reservation
      await ReservationService().updateReservationData(
        date: updated.appointmentDateTime ?? "",
        isPatient: true,
        doctorUid: updated.doctorKey,
        reservation: updated,
        localOnly: false,
        voidCallBack: (_) {},
      );

      // 2️⃣ Update patient meta
      await ReservationService().updatePatientReservationData(
        key: updated.key ?? "",
        data: updated,
        voidCallBack: (_) {},
      );
    }
    await _updateClientsSyncStatus();
    debugPrint("✅ [FCM SYNC] Finished updating tokens");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    // 🔄 Reload reservations
    getReservations();
  }

  Future<void> _updateClientsSyncStatus() async {
    final ref = FirebaseDatabase.instance.ref("sync_meta/clients");

    await ref.update({
      "last_add_data_timestamp": DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> setupDefaultDate() async {
    final now = DateTime.now();
    appointment_date_time = DateFormat('dd/MM/yyyy').format(now);

    totalCompleted = await getCompletedCountForToday();

    update();
  }

  Future<int> getCompletedCountForToday() async {
    final String? date = appointment_date_time;
    int count = 0;

    if (date == null) return 0;

    await ReservationService().getReservationsData(
      data: FirebaseFilter(orderBy: "appointment_date_time", equalTo: date),
      query: SQLiteQueryParams(), // ignored online
      voidCallBack: (list) {
        count = list
            .whereType<ReservationModel>()
            .where((r) => r.status == ReservationStatus.completed.value)
            .length;
      },
    );

    return count;
  }

  int calculateAheadCount(ReservationModel current) {
    if (listReservations == null || listReservations!.isEmpty) {
      return 0;
    }

    final myOrder = current.order_num ?? 0;
    if (myOrder == 0) return 0;

    final activeOnlineAhead = listReservations!
        .whereType<ReservationModel>()
        .where((r) {
          final sameDay = r.appointmentDateTime == current.appointmentDateTime;

          final rOrder = r.order_num ?? 0;
          if (rOrder == 0) return false;

          final isBeforeMe = rOrder < myOrder;

          final isActive =
              r.status == ReservationStatus.pending.value ||
              r.status == ReservationStatus.approved.value ||
              r.status == ReservationStatus.inProgress.value;

          return sameDay && isBeforeMe && isActive;
        })
        .length;

    // 🔥 legacy محسوب وموجود
    return legacyQueueCount + activeOnlineAhead;
  }

  Future<List<ReservationModel?>> loadMyReservations() async {
    final patientKey = LocalUser().getUserData().key ?? "";
    if (patientKey.isEmpty) return [];

    // Loader.show();

    // 1) جِب الميتا كـ Future
    final metaList = await ReservationService().getPatientMetaAsync(patientKey);
    // 3) فرز NEW -> OLD
    metaList.sort((a, b) {
      final int timeA = a.createAt ?? 0;
      final int timeB = b.createAt ?? 0;
      return timeB.compareTo(timeA);
    });

    Loader.dismiss();
    update();

    return metaList;
  }

  void getReservations() {
    final patientKey = LocalUser().getUserData().key ?? "";

    ReservationService().getPatientReservationsMeta(
      patientKey: patientKey,
      voidCallBack: (list) async {
        listReservations = list;

        await syncMissingFcmTokenForMyReservations();

        // 🔥 أول reservation نستخدمها
        final first = list.whereType<ReservationModel>().firstOrNull;

        if (first != null) {
          final legacyDate = DateFormat(
            'dd-MM-yyyy',
          ).format(DateFormat('dd/MM/yyyy').parse(first.appointmentDateTime!));

          await loadLegacyQueueCount(
            doctorUid: first.doctorKey ?? "",
            clinicKey: first.clinicKey ?? "",
            date: legacyDate,
          );

          print("🔥 legacyQueueCount = $legacyQueueCount");
        }

        update();
      },
    );
  }

  void getSyncReservations({bool? initLocalData}) {
    syncService.listen(
      selectedClinic: selectedClinic,
      appointmentDate: appointment_date_time,
      onAddLocal: (model) async {
        initLocalData = null;
        getReservations();
      },
      onUpdatedLocal: (model) async {
        initLocalData = null;
        await updateReservation(model, localOnly: true);
      },
      onReloadLocal: () {
        if (initLocalData == null) {
          getReservations();
        }
      },
    );
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

    AuthenticationService().getSingleClientsData(
      filrebaseFilter: FirebaseFilter(
        equalTo: reservation.patientKey!,
        orderBy: "key",
      ),
      voidCallBack: (user) {
        Loader.dismiss();

        if (user == null) {
          Loader.showError("لم يتم العثور على بيانات العميل");
          return;
        }

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

  void openPrescriptionBottomSheet({
    required BuildContext context,
    required ReservationModel reservation,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => PrescriptionPatientBottomSheetWidget(
        reservation: reservation,
        onUpdated: () {
          getReservations();
          HomePatientController controller = initController(
            () => HomePatientController(),
          );
          controller.reservationVM.getReservations();
          controller.update();
          update();
        },
      ),
    );
  }

  Future<void> addFeedBack(
    DoctorReviewModel review,
    ReservationModel reservation,
  ) async {
    try {
      // 🟢 Save review to Firebase
      await DoctorReviewService().addDoctorFromPatientReviewData(
        review: review,
        doctorKey: review.doctorId ?? "",
        voidCallBack: (status) async {
          if (status == ResponseStatus.success) {
            // mark reservation as having feedback
            reservation.hasFeedback = true;
            // 🔄 Update reservation in SQLite + sync
            await ReservationService().updateReservationData(
              date: reservation.appointmentDateTime ?? "",
              reservation: reservation,
              doctorUid: reservation.doctorKey,
              isPatient: true,
              voidCallBack: (_) {
                ReservationService().updatePatientReservationData(
                  key: reservation.key ?? "",
                  data: reservation,
                  voidCallBack: (_) {
                    getReservations();
                    HomePatientController controller = initController(
                      () => HomePatientController(),
                    );
                    controller.reservationVM.getReservations();
                    controller.update();

                    update();
                  },
                );
                update();
              },
            );

            Loader.showSuccess("تم إرسال التقييم بنجاح");
          } else {
            Loader.showError("حدث خطأ أثناء إرسال التقييم");
          }
        },
      );
    } catch (e) {
      Loader.showError("تعذر إرسال التقييم: $e");
    }
  }

  /// Fetch reservations from local SQLite (same filtering style as assistant ViewModel)

  /// Same urgent policy queue builder as assistant VM
  List<ReservationModel> buildFinalQueue(
    List<ReservationModel> list,
    int urgentPolicy,
  ) {
    // 1️⃣ Split list into urgent and normal
    List<ReservationModel> urgentList = [];
    List<ReservationModel> normalList = [];

    for (var r in list) {
      if (r.reservationType == "كشف مستعجل") {
        urgentList.add(r);
      } else {
        normalList.add(r);
      }
    }

    // 2️⃣ Build final reordered list
    List<ReservationModel> finalQueue = [];
    int normalCount = 0;

    while (normalList.isNotEmpty || urgentList.isNotEmpty) {
      // Add normal until reaching urgentPolicy
      if (normalList.isNotEmpty) {
        finalQueue.add(normalList.removeAt(0));
        normalCount++;
      }

      // Insert urgent when normalCount reaches policy
      if (normalCount == urgentPolicy && urgentList.isNotEmpty) {
        finalQueue.add(urgentList.removeAt(0));
        normalCount = 0;
      }

      // When no normals left, ONLY THEN push urgents
      if (normalList.isEmpty &&
          urgentList.isNotEmpty &&
          normalCount != urgentPolicy) {
        finalQueue.add(urgentList.removeAt(0));
        // ⭐ important: DO NOT RESET normalCount HERE
      }
    }

    // 3️⃣ Assign order_reserved sequentially
    for (int i = 0; i < finalQueue.length; i++) {
      final updated = finalQueue[i].copyWith(order_reserved: i + 1);
      finalQueue[i] = updated;

      updateReservation(updated, localOnly: true);
    }

    return finalQueue;
  }

  /// Update reservation locally / remotely
  Future<void> updateReservation(
    ReservationModel reservation, {
    bool localOnly = false,
  }) async {
    await ReservationService().updateReservationData(
      date: reservation.appointmentDateTime ?? "",
      isPatient: true,
      doctorUid: reservation.doctorKey,
      reservation: reservation,
      localOnly: localOnly,
      voidCallBack: (_) {
        updatePatientReservation(reservation);
        Loader.dismiss();
      },
    );
  }

  /// Update reservation locally / remotely
  Future<void> updatePatientReservation(ReservationModel reservation) async {
    await ReservationService().updatePatientReservationData(
      data: reservation,
      key: reservation.key ?? "",

      voidCallBack: (_) {
        getReservations();
        HomePatientController controller = initController(
          () => HomePatientController(),
        );
        controller.reservationVM.getReservations();
        controller.fetchOrders();
        controller.update();
        Loader.dismiss();
      },
    );
  }

  /// Delete reservation
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
}
