import 'package:intl/intl.dart';
import '../../../../../index/index_main.dart';

class DoctorDetailsViewModel extends GetxController {
  final LocalUser doctor;
  int? nextOrder;
  List<DoctorReviewModel?>? listReviews;
  int? beforeYouCount;
  int? expectedOrder;
  bool isLoadingOrderInfo = false;
  int legacyQueueCount = 0;
  int completedCount = 0;
  LegacyQueueModel? legacyQueueForDay;
  bool isSelectedDayClosed = false;
  bool get isUrgentReservation =>
      selectedReservationType == "كشف مستعجل";

  DoctorDetailsViewModel({required this.doctor});

  // ─────────────────────────────────────────────
  // 🔹 Data Sources
  List<ClinicModel> listClinics = [];
  List<ShiftModel?>? listShifts;
  List<LocalUser?>? assisList;

  // 🔹 Dropdown-ready Lists
  List<GenericListModel> clinicItems = [];
  List<GenericListModel> shiftItems = [];
  List<GenericListModel> reservationTypeItems = [];

  // 🔹 Selected Items
  ClinicModel? selectedClinic;
  ShiftModel? selectedShift;
  String? selectedReservationType;
  DateTime? selectedDate;

  // 🔹 Loading States
  bool isLoadingClinics = true;
  bool isLoadingShifts = false;

  int selectedTabIndex = 0;

  // 🔹 Reservation Types
  final List<String> reservationTypes = ["كشف جديد", "كشف مستعجل", "إعادة"];

  // ─────────────────────────────────────────────
  // 🔹 Price + Deposit Info
  double? selectedPrice;
  double? depositPercent;
  double? depositAmount;
  late final LocalUser currentUser;

  @override
  void onInit() {
    super.onInit();

    final user = Get.find<UserSession>().user;

    if (user == null) {
      throw Exception("User not initialized");
    }

    currentUser = user;

    selectedDate = DateTime.now();
    _loadClinics();

    getDoctorData();
    _initReservationTypes();
  }

  String _formatLegacyDate(DateTime date) {
    return DateFormat("dd-MM-yyyy").format(date);
  }

  void changeTab(int index) {
    selectedTabIndex = index;
    update();
  }

  void getDoctorData() {
    DoctorReviewService().getDoctorReviewsFromPatientData(
      data: {},
      doctorKey: doctor.uid ?? "",
      voidCallBack: (data) {
        Loader.dismiss();
        listReviews = data;
        update();
      },
    );
    update();
  }

  // ─────────────────────────────────────────────
  // 🔹 Setup Reservation Types
  void _initReservationTypes() {
    reservationTypeItems =
        reservationTypes
            .asMap()
            .entries
            .map((e) => GenericListModel(key: 'type_${e.key}', name: e.value))
            .toList();
  }

  Future<void> loadExpectedOrderFromExistingData() async {
    if (selectedClinic == null ||
        selectedShift == null ||
        selectedDate == null) {
      beforeYouCount = null;
      expectedOrder = null;
      isLoadingOrderInfo = false;
      update();
      return;
    }

    isLoadingOrderInfo = true;
    update();

    final formattedDate = DateFormat("dd-MM-yyyy").format(selectedDate!);
    int activeCount = 0;

    final result = await ReservationService().useCase.fetchReservationsOnce(
      doctorKey: doctor.uid ?? "",
      date: formattedDate,
    );

    result.fold(
      (error) {
        beforeYouCount = null;
        expectedOrder = null;
      },
      (list) {
        for (final r in list) {
          // 🔥 فلترة أساسية
          if (r.clinicKey != selectedClinic?.key) continue;
          if (r.shiftKey != selectedShift?.key) continue;

          // 🔥 active فقط
          if (r.status == ReservationStatus.pending.value ||
              r.status == ReservationStatus.approved.value ||
              r.status == ReservationStatus.inProgress.value) {
            activeCount++;
          }
        }

        // ✅ الحساب الصح
        beforeYouCount = legacyQueueCount + activeCount;
        expectedOrder = beforeYouCount! + 1;
      },
    );

    isLoadingOrderInfo = false;
    update();
  }

  Future<int> getTodayActiveReservationsCount() async {
    if (selectedClinic == null ||
        selectedShift == null ||
        selectedDate == null) {
      return 0;
    }

    final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate!);

    int count = 0;

    await ReservationService().getReservationsData(
      query: SQLiteQueryParams(),
      voidCallBack: (list) {
        count =
            list
                .where(
                  (r) =>
                      r != null &&
                      (r.status == ReservationStatus.approved.value ||
                          r.status == ReservationStatus.inProgress.value),
                )
                .length;
      },
    );

    return count;
  }

  Future<void> getAssistantData() async {
    await AuthenticationService().getClientsData(
      query: SQLiteQueryParams(
        where: "clinic_key = ?",
        whereArgs: [selectedClinic?.key ?? ""],
      ),
      voidCallBack: (users) async {
        Loader.dismiss();
        assisList = users;
        update();
      },
    );
  }

  // ─────────────────────────────────────────────
  // 🔹 Load Clinics
  Future<void> _loadClinics() async {
    isLoadingClinics = true;
    update();

    try {
      final uid = doctor.uid?.trim() ?? "";

      await ClinicService().getClinicsFromPatientData(
        data: {},
        doctorKey: uid,
        voidCallBack: (data) async {
          Loader.dismiss();

          // ✅ دايمًا list نظيفة
          listClinics = data.whereType<ClinicModel>().toList();

          isLoadingClinics = false;

          // ✅ dropdown
          clinicItems =
              listClinics
                  .map(
                    (c) => GenericListModel(
                      key: c.key ?? "",
                      name: c.title ?? "عيادة بدون اسم",
                    ),
                  )
                  .toList();

          // ❗ مهم: reset القديم
          selectedClinic = null;
          selectedShift = null;

          // ✅ اختار أول عيادة لو موجودة
          if (listClinics.isNotEmpty) {
            selectedClinic = listClinics?.first;

            // 🔥 حمل الشيفتات (هي اللي تحدد selectedShift)
            await _loadShiftsForClinic(selectedClinic!);

            // ✅ أمان 100%
            if (selectedClinic != null &&
                selectedShift != null &&
                selectedDate != null) {
              await loadLegacyQueueForSelectedDate();
              await loadOpenCloseStatusForSelectedDate();
            }
          }

          // ✅ assistants
          await getAssistantData();

          update();
        },
      );
    } catch (e) {
      Loader.dismiss();

      Loader.showError("حدث خطأ أثناء تحميل بيانات العيادات");

      isLoadingClinics = false;
      update();
    }
  } // ─────────────────────────────────────────────

  // 🔹 Select Clinic
  Future<void> onSelectClinic(ClinicModel clinic) async {
    selectedClinic = clinic;
    await _loadShiftsForClinic(clinic);
  }

  // ─────────────────────────────────────────────
  // 🔹 Load Shifts for Selected Clinic
  // ─────────────────────────────────────────────
  // 🔹 Load Shifts for Selected Clinic
  Future<void> _loadShiftsForClinic(ClinicModel clinic) async {
    isLoadingShifts = true;
    selectedShift = null;
    update();

    try {
      final doctorKey = doctor.uid ?? "";

      // 🩺 Fetch all shifts related to this doctor
      await ShiftService().getShiftssFromPatientData(
        data: {},
        doctorKey: doctorKey,
        voidCallBack: (data) {
          Loader.dismiss();

          // 🔍 Filter shifts by clinicKey
          final filteredShifts =
              (data)
                  .whereType<ShiftModel>()
                  .where((s) => s.clinicKey == clinic.key)
                  .toList();

          listShifts = filteredShifts;

          // 🧩 Convert to dropdown items
          shiftItems =
              filteredShifts
                  .map(
                    (s) => GenericListModel(
                      key: s.key ?? "",
                      name: "${s.name ?? "فترة"} (${s.dayOfWeek ?? ""})",
                    ),
                  )
                  .toList();

          selectedShift = listShifts?.first;
          isLoadingShifts = false;
          update();
        },
      );
    } catch (e, stack) {
      Loader.dismiss();
      //  Loader.showError("فشل تحميل الفترات");
      debugPrint("❌ [Shifts] Error while loading shifts: $e");
      debugPrint(stack.toString());
      isLoadingShifts = false;
      update();
    }
  }

  void onSelectReservationType(String type) {
    selectedReservationType = type;
    _calculatePrices();
    update();
  }

  // void onSelectDate(DateTime date) {
  //   selectedDate = date;
  //   getTodayActiveReservationsCount(); // ✅ add this
  //   update();
  // }

  void onSelectDate(DateTime date) {
    selectedDate = date;

    loadLegacyQueueForSelectedDate(); // الدور
    loadOpenCloseStatusForSelectedDate(); // 🔥 check open/close
  }

  // ─────────────────────────────────────────────
  // 🔹 Calculate Prices + Deposit
  void _calculatePrices() {
    if (selectedClinic == null) return;

    final clinic = selectedClinic!;
    double price = 0;

    switch (selectedReservationType) {
      case "كشف مستعجل":
        price = double.tryParse(clinic.urgentConsultationPrice ?? "0") ?? 0.0;
        break;
      case "إعادة":
        price = double.tryParse(clinic.followUpPrice ?? "0") ?? 0.0;
        break;
      default:
        price = double.tryParse(clinic.consultationPrice ?? "0") ?? 0.0;
    }

    selectedPrice = price;
    depositPercent = clinic.minimumDepositPercent ?? 0.0;
    depositAmount = (price * (depositPercent ?? 0)) / 100;
  }

  // ─────────────────────────────────────────────

  // ─────────────────────────────────────────────
  // 🔹 Confirm Reservation
  Future<void> confirmReservation({String? transfer_url_image}) async {
    // 🔹 Step 1: Validate user selections
    if (selectedClinic == null ||
        selectedShift == null ||
        selectedReservationType == null ||
        selectedDate == null) {
      Loader.showError("⚠️ من فضلك أكمل جميع البيانات قبل تأكيد الحجز");
      return;
    }

    try {
      Loader.show();

      // 🔹 Step 2: Prepare keys and format date
      final formattedDate = DateFormat("dd-MM-yyyy").format(selectedDate!);

      final clinicKey = selectedClinic?.key ?? "";
      final shiftKey = selectedShift?.key ?? "";

      // 🔹 Step 4: Determine pricing
      double? totalAmount;
      switch (selectedReservationType) {
        case "كشف مستعجل":
          totalAmount = double.tryParse(
            selectedClinic?.urgentConsultationPrice ?? "0",
          );
          break;
        case "إعادة":
          totalAmount = double.tryParse(selectedClinic?.followUpPrice ?? "0");
          break;
        default:
          totalAmount = double.tryParse(
            selectedClinic?.consultationPrice ?? "0",
          );
          break;
      }

      final depositPercent = selectedClinic?.minimumDepositPercent ?? 0;
      final depositAmount = (totalAmount ?? 0) * (depositPercent / 100);
      final totalOrder = await getTodayActiveReservationsCount();
      nextOrder = totalOrder + 1;

      // 🔹 Step 5: Build Reservation model
      final reservation = ReservationModel(
        key: const Uuid().v4(),
        doctorUid: doctor.uid,
        doctorName: doctor.name,
        doctorFcm: doctor.fcmToken,
        transferImage: transfer_url_image,

        // ✅ user من session
        patientFcm: currentUser.fcmToken,
        patientName: currentUser.name,
        patientPhone: currentUser.phone,
        patientUid: currentUser.uid,

        clinicKey: clinicKey,
        orderNum: expectedOrder,
        shiftKey: shiftKey,

        reservationType: selectedReservationType,
        appointmentDateTime: formattedDate,
        createdAt: DateTime.now().millisecondsSinceEpoch,

        paidAmount:
            selectedClinic?.reserveWithDeposit == 1
                ? depositAmount.toStringAsFixed(2)
                : totalAmount?.toStringAsFixed(2),

        restAmount:
            selectedClinic?.reserveWithDeposit == 1
                ? ((totalAmount ?? 0) - depositAmount).toStringAsFixed(2)
                : "0",

        status: ReservationStatus.pending.value,
      );
      // 🔹 Step 6: Save reservation in Firebase & local DB
      await ReservationService().addReservationData(
        reservation: reservation,
        voidCallBack: (_) async {
          await addPatientReservation(reservation);
          // 1️⃣ إعادة ترتيب الطابور

          await NotificationHandler().sendToClinicAssistants(
            reservation: reservation,
            title: "🩺 حجز جديد",
            body:
                "حجز جديد من ${reservation.patientName} بتاريخ ${reservation.appointmentDateTime}",
            notificationType: "new_reservation",

            assistants: assisList ?? [],
          );

          Loader.dismiss();

          // 3️⃣ العودة للصفحة الرئيسية
          Get.off(() => ReservationSuccessScreen(reservation: reservation));
        },
      );
    } catch (e) {
      Loader.dismiss();
      Loader.showError("❌ حدث خطأ أثناء إنشاء الحجز: $e");
      debugPrint("Reservation creation error: $e");
    }
  }

  Future<void> addPatientReservation(ReservationModel model) async {
    await PatientReservationService().addReservationData(
      reservation: model,
      voidCallBack: (status) {
        if (status == ResponseStatus.success) {
        } else {}
      },
    );
  }

  // ─────────────────────────────────────────────
  // 🔹 Validation
  bool get isReservationValid {
    return selectedClinic != null &&
        selectedShift != null &&
        selectedReservationType != null &&
        selectedDate != null;
  }
}

extension LoadApis on DoctorDetailsViewModel {
  Future<void> loadOpenCloseStatusForSelectedDate() async {
    isSelectedDayClosed = false;

    if (selectedDate == null) {
      update();
      return;
    }

    final date = DateFormat("dd-MM-yyyy").format(selectedDate!);

    await LegacyQueueService().getOpenCloseDaysByDateData(
      date: date,
      isPatient: true,
      doctorUid: doctor.uid,
      firebaseFilter: FirebaseFilter(
        orderBy: "clinicShiftKey",
        equalTo: "${selectedClinic?.key}_${selectedShift?.key}",
      ),
      voidCallBack: (data) {
        if (data.isNotEmpty) {
          final item = data.first;
          if (item?.isClosed == true) {
            isSelectedDayClosed = true;
          }
        }
        update();
      },
    );
  }

  Future<void> loadLegacyQueueForSelectedDate() async {
    if (selectedClinic == null || selectedDate == null) {
      legacyQueueCount = 0;
      beforeYouCount = null;
      expectedOrder = null;
      update();
      return;
    }

    isLoadingOrderInfo = true;
    update();

    final myClinicKey = selectedClinic!.key;
    final date = _formatLegacyDate(selectedDate!);

    legacyQueueCount = 0;
    legacyQueueForDay = null;

    await LegacyQueueService().getLegacyQueueByDateData(
      isPatient: true,
      firebaseFilter: FirebaseFilter(
        orderBy: "clinicShiftKey",
        equalTo: "${selectedClinic?.key}_${selectedShift?.key}",
      ),
      doctorUid: doctor.uid,
      voidCallBack: (data) {
        for (final item in data) {
          if (item == null) continue;

          if (item.clinic_key == myClinicKey) {
            legacyQueueCount = item.value ?? 0;
            legacyQueueForDay = item;
            break;
          }
        }

        // 🔥 بعد ما legacy اتحسب → احسب الدور
        loadExpectedOrderFromExistingData();
      },
    );
  }
}
