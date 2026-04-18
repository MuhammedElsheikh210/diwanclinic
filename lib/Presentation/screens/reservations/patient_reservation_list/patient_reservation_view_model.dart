import 'dart:io';

import 'package:diwanclinic/Presentation/parentControllers/patientReservationService.dart';
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
      final int timeA = a?.createdAt ?? 0;
      final int timeB = b?.createdAt ?? 0;
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
  void onInit() {
    super.onInit();

    startRealtimeReservations(); // ✅ هنا الصح
  }

  Future<void> startRealtimeReservations() async {
    final service = PatientReservationService(); // ✅ FIX (مش new)

    final patientUid = Get.find<UserSession>().user?.uid;

    if (patientUid == null || patientUid.isEmpty) {
      
      return;
    }


    listReservations = [];

    // ➕ ADDED
    service.onReservationAdded = (reservation) {
      
      _updateList(reservation);
    };

    // 🔄 UPDATED
    service.onReservationUpdated = (reservation) {
      
      _updateList(reservation);
    };

    // ❌ REMOVED
    service.onReservationRemoved = (key) {
      

      listReservations?.removeWhere((e) => e?.key == key);

      update();
    };
  }

  void _updateList(ReservationModel model) {
    listReservations ??= [];

    final index = listReservations!.indexWhere((e) => e?.key == model.key);

    if (index != -1) {
      listReservations![index] = model;
    } else {
      listReservations!.insert(0, model);
    }

    // 🔥 مهم جدًا علشان ترتيب الريل تايم
    listReservations!.sort(
      (a, b) => (b?.createdAt ?? 0).compareTo(a?.createdAt ?? 0),
    );

    update();
  }

  Future<void> loadLegacyQueueCount({
    required String doctorUid,
    required String clinicKey,
    required String date,
  }) async {
    legacyQueueCount = 0;

    await LegacyQueueService().getLegacyQueueByDateData(
      isPatient: true,
      firebaseFilter: FirebaseFilter(
        orderBy: "clinicShiftKey",
        equalTo: "${clinicKey}_${selectedShift?.key}",
      ),
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
    final user = Get.find<UserSession>().user;

    final String? myUid = user?.uid;
    final String? myToken = user?.fcmToken;

    if (myUid == null || myUid.isEmpty) {
      
      return;
    }

    if (myToken == null || myToken.isEmpty) {
      
      return;
    }

    
    
    
    
    

    final reservations =
        listReservations
            ?.whereType<ReservationModel>()
            .where(
              (r) =>
                  r.patientUid == myUid &&
                  (r.patientFcm == null || r.patientFcm!.isEmpty),
            )
            .toList() ??
        [];

    if (reservations.isEmpty) {
      
      return;
    }

    

    for (final r in reservations) {
      final updated = r.copyWith(patientFcm: myToken);

      

      // 1️⃣ Update main reservation
      await ReservationService().updateReservationData(
        reservation: updated,
        voidCallBack: (_) {},
      );

      await PatientReservationService().updateReservationData(
        reservation: updated,
        voidCallBack: (_) {},
      );
    }
    await _updateClientsSyncStatus();
    
    
  }

  Future<void> _updateClientsSyncStatus() async {
    final ref = FirebaseDatabase.instance.ref("sync_meta/clients");

    await ref.update({
      "last_add_data_timestamp": DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> setupDefaultDate() async {
    final now = DateTime.now();
    appointment_date_time = DateFormat('dd-MM-yyyy').format(now);

    totalCompleted = await getCompletedCountForToday();

    update();
  }

  Future<int> getCompletedCountForToday() async {
    final String? date = appointment_date_time;
    int count = 0;

    if (date == null) return 0;

    await ReservationService().getReservationsData(
      query: SQLiteQueryParams(), // ignored online
      voidCallBack: (list) {
        count =
            list
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

    final myOrder = current.orderNum ?? 0;
    if (myOrder == 0) return 0;

    final activeOnlineAhead =
        listReservations!.whereType<ReservationModel>().where((r) {
          final sameDay = r.appointmentDateTime == current.appointmentDateTime;

          final rOrder = r.orderNum ?? 0;
          if (rOrder == 0) return false;

          final isBeforeMe = rOrder < myOrder;

          final isActive =
              r.status == ReservationStatus.pending.value ||
              r.status == ReservationStatus.approved.value ||
              r.status == ReservationStatus.inProgress.value;

          return sameDay && isBeforeMe && isActive;
        }).length;

    return legacyQueueCount + activeOnlineAhead;
  }

  Future<void> openOrderConfirmationSheet({
    required BuildContext context,
    required ReservationModel reservation,
  }) async {
    if (reservation.patientUid == null) {
      Loader.showError("بيانات العميل غير متوفرة");
      return;
    }

    Loader.show();

    AuthenticationService().getClientsData(
      query: SQLiteQueryParams(
        where: "key = ?",
        whereArgs: [reservation.patientUid!],
        limit: 1,
      ),
      voidCallBack: (users) {
        Loader.dismiss();

        if (users.isEmpty || users.first == null) {
          Loader.showError("لم يتم العثور على بيانات العميل");
          return;
        }

        final user = users.first!;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder:
              (_) => OrderConfirmationSheet(
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
      builder:
          (_) => PrescriptionPatientBottomSheetWidget(
            reservation: reservation,
            onUpdated: () {
              // getReservations();
              // HomePatientController controller = initController(
              //   () => HomePatientController(),
              // );
              // controller.reservationVM.getReservations();
              // controller.update();
              // update();
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
              reservation: reservation,

              voidCallBack: (_) async {
                await PatientReservationService().updateReservationData(
                  reservation: reservation,
                  voidCallBack: (_) {
                    // HomePatientController controller = initController(
                    //   () => HomePatientController(),
                    // );
                    //
                    // controller.update();
                    // update();
                  },
                );
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
      final updated = finalQueue[i].copyWith(orderReserved: i + 1);
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
      reservation: reservation,
      voidCallBack: (_) {
        updatePatientReservation(reservation);
        Loader.dismiss();
      },
    );
  }

  Future<void> updatePatientReservation(ReservationModel reservation) async {
    await PatientReservationService().updateReservationData(
      reservation: reservation,
      voidCallBack: (_) {},
    );
  }

  /// Delete reservation
  void deleteReservation(ReservationModel reservation) {
    ReservationService().deleteReservationData(
      reservationKey: reservation.key ?? "",
      voidCallBack: (_) => {},
    );
  }

  void resetFilters() {
    selectedClinic = null;
    selectedShift = null;
    selectedStatus = null;
    create_at = null;
    _isInitialLoad = true;
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
          update();
        },
      });
    }
    if (selectedShift != null) {
      filters.add({
        "label": "الوردية: ${selectedShift?.name ?? ''}",
        "onRemove": () {
          selectedShift = null;
          update();
        },
      });
    }
    if (selectedStatus != null) {
      filters.add({
        "label": "الحالة: ${selectedStatus!.label}",
        "onRemove": () {
          selectedStatus = null;
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
          update();
        },
      });
    }
    return filters;
  }
}
