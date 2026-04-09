import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class CreateReservationViewModel extends GetxController {
  // Patient info (mapped to LocalUser)
  final TextEditingController patientCodeController = TextEditingController();
  final TextEditingController patientPhoneController = TextEditingController();
  final TextEditingController patientNameController = TextEditingController();
  String? lastReservationHumanText;
  bool isFromLegacyQueue = false;
  int legacyQueueCount = 0;
  LegacyQueueModel? currentLegacyQueue;
  bool isDayClosed = false;
  List<ShiftModel?>? shiftList;
  List<GenericListModel> shiftItems = [];
  GenericListModel? selectedShiftModel;
  bool isLoadingShifts = false;

  int _calcRequestId = 0;
  bool isCalculatingOrder = false;

  // Delegate fields
  final TextEditingController delegateNameController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();

  // Payment fields
  final TextEditingController paidAmountController = TextEditingController();
  final TextEditingController restAmountController = TextEditingController();
  final TextEditingController resOrderController = TextEditingController();
  ClinicModel? selectedClinic;
  List<ReservationModel> ordinaryReservations = [];
  List<ReservationModel> urgentReservations = [];
  bool isLoadingReservations = false;

  List<LocalUser?>? centerDoctors;
  LocalUser? selectedDoctor;
  bool isLoadingDoctors = false;

  bool get isCenterAssistant =>
      LocalUser().getUserData().medicalCenterKey != null;

  // 🔹 Reservation date
  int? create_at = DateTime.now().millisecondsSinceEpoch;

  static String get uid {
    final user = LocalUser().getUserData();
    return user.uid ?? "";
  }

  ReservationModel? existingReservation;
  LocalUser? clientUser;
  bool is_update = false;
  String? clinic_key;
  String? shift_key;
  String? doctor_key;
  String? selectedType;
  String? patient_name;
  bool _isPopulating = false;

  final List<String> typeOptions = [
    "كشف جديد",
    "كشف مستعجل",
    "إعادة",
    "متابعة",
  ];

  // 🔹 Prices from Clinic
  String? consultationPrice;
  String? followUpPrice;
  String? urgentConsultationPrice;
  ClinicModel? clinicModel;
  int? totalAmount;
  final AuthenticationService clientService = AuthenticationService();
  int currentStep = 1;

  void nextStep() {
    if (currentStep < 3) {
      currentStep++;
      update();
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
      update();
    }
  }

  bool validateStep1() {
    return companyNameController.text.isNotEmpty &&
        (!isFromLegacyQueue || resOrderController.text.isNotEmpty);
  }

  bool validateStep2() {
    return patientNameController.text.isNotEmpty &&
        patientPhoneController.text.isNotEmpty;
  }

  bool validateStep3() {
    return selectedType != null && paidAmountController.text.isNotEmpty;
  }

  bool validateCurrentStep() {
    if (currentStep == 1) return validateStep1();
    if (currentStep == 2) return validateStep2();
    if (currentStep == 3) return validateStep3();
    return false;
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    // if (isCenterAssistant) {
    //   loadDoctorsOfCenter();
    // }
    patientNameController.addListener(_triggerUpdate);
    resOrderController.addListener(_triggerUpdate);
    patientPhoneController.addListener(_convertPhoneToEnglish);
    patientCodeController.addListener(_triggerUpdate);
    paidAmountController.addListener(_triggerUpdate);
    paidAmountController.addListener(_updateRestAmount);
  }

  Future<void> onDoctorChanged(LocalUser doctor) async {
    selectedDoctor = doctor;

    /// 🔥 متعملش reset لو فيه shift جاي من برا
    if (shift_key == null) {
      selectedShiftModel = null;
    }

    /// 1️⃣ reload shifts
    await loadShiftsForClinic();

    final date = companyNameController.text;

    if (date.isEmpty) {
      update();
      return;
    }

    final formattedDate = date.contains('/') ? normalizeToDashDate(date) : date;

    /// 2️⃣ open/close
    await loadOpenCloseStatusForDate(formattedDate);

    await calculateOrderNumber();

    update();
  }

  Future<void> calculateOrderNumber() async {
    if (clinic_key == null || shift_key == null) return;

    final doctorUid =
        isCenterAssistant
            ? selectedDoctor?.uid
            : LocalUser().getUserData().doctorKey;

    if (doctorUid == null || doctorUid.isEmpty) return;

    final date = companyNameController.text;
    if (date.isEmpty) return;

    final formatted = date.contains('/') ? normalizeToDashDate(date) : date;

    final requestId = ++_calcRequestId;

    isCalculatingOrder = true;

    /// 🔥🔥🔥 أهم سطر (الحل)
    legacyQueueCount = 0;

    update();

    try {
      /// 1️⃣ load legacy
      await loadLegacyQueueForDate(formatted);

      if (requestId != _calcRequestId) return;

      /// 2️⃣ last order
      int lastOrder = 0;

      await ReservationService().getReservationsData(
        query: SQLiteQueryParams(
          where: """
        appointment_date_time = ?
        AND clinic_key = ?
        AND shift_key = ?
        AND doctor_key = ?
      """,
          whereArgs: [formatted, clinic_key, shift_key, doctorUid],
          orderBy: "order_num DESC",
          limit: 1,
        ),
        voidCallBack: (list) {
          if (list.isNotEmpty) {
            lastOrder = list.first?.order_num ?? 0;
          }
        },
      );

      if (requestId != _calcRequestId) return;

      /// 3️⃣ calculate
      if (!isFromLegacyQueue) {
        final base =
            lastOrder > legacyQueueCount ? lastOrder : legacyQueueCount;

        resOrderController.text = (base + 1).toString();
      } else {
        resOrderController.clear();
      }
    } catch (e) {
      print("❌ error: $e");
    }

    isCalculatingOrder = false;
    update();
  }

  Future<void> loadDoctorsOfCenter() async {
    final centerKey = LocalUser().getUserData().medicalCenterKey;
    if (centerKey == null) return;

    isLoadingDoctors = true;
    update();

    AuthenticationService().getClientsData(
      query: SQLiteQueryParams(
        where: "medicalCenterKey = ? AND userType = ?",
        whereArgs: [centerKey, "doctor"],
      ),
      voidCallBack: (data) async {
        centerDoctors = data;

        /// 🔥 IMPORTANT: set default doctor
        if (data != null && data.isNotEmpty) {
          try {
            /// ✅ حاول تختار الدكتور اللي جاي من الشاشة
            selectedDoctor = data.firstWhere((doc) => doc?.uid == doctor_key);
          } catch (_) {
            /// 🔁 fallback لأول دكتور
            selectedDoctor = data.first;
          }

          /// 🔥 بعد ما الدكتور يتحدد → حمل كل حاجة زيه زي onDoctorChanged
        }

        isLoadingDoctors = false;
        update();

        /// 🔥 وبعدها حمّل البيانات في background
        Future.microtask(() async {
          if (selectedDoctor != null) {
            await onDoctorChanged(selectedDoctor!);
          }
        });
      },
    );
  }

  Future<void> loadOpenCloseStatusForDate(String date) async {
    isDayClosed = false;

    /// 🔥 مهم
    if (shift_key == null || shift_key!.isEmpty) {
      return;
    }

    final shiftDate = "${shift_key}_$date";

    LegacyQueueService().getOpenCloseDaysByDateData(
      date: date,
      doctorUid: isCenterAssistant ? selectedDoctor?.uid : null,

      firebaseFilter: FirebaseFilter(
        orderBy: "shift_date", // ✅ الجديد
        equalTo: shiftDate,
      ),

      voidCallBack: (data) {
        if (data.isNotEmpty) {
          final item = data.first;

          if (item != null && item.isClosed == true) {
            isDayClosed = true;
          }
        }

        update();
      },
    );
  }

  void _convertPhoneToEnglish() {
    final text = patientPhoneController.text;
    final converted = convertArabicToEnglishNumbers(text);

    if (text != converted) {
      patientPhoneController.value = patientPhoneController.value.copyWith(
        text: converted,
        selection: TextSelection.collapsed(offset: converted.length),
      );
    }

    update();
  }

  Future<void> loadShiftsForClinic() async {
    /// ✅ safety check
    if (clinic_key == null || clinic_key!.isEmpty) {
      print("❌ clinic_key is null → skip shifts");
      return;
    }

    /// ✅ center لازم يبقى فيه دكتور
    if (isCenterAssistant && (selectedDoctor?.uid == null)) {
      print("❌ selectedDoctor is null → skip shifts");
      return;
    }

    isLoadingShifts = true;
    update();

    final doctorUid =
        isCenterAssistant
            ? selectedDoctor?.uid
            : LocalUser().getUserData().doctorKey ?? "";

    print("👨‍⚕️ doctorUid: $doctorUid");
    print("🏥 clinic_key: $clinic_key");
    print("📌 passed shift_key: $shift_key");

    try {
      await ShiftService().getShiftsData(
        data: FirebaseFilter(orderBy: "clinicKey", equalTo: clinic_key),

        doctorKey: doctorUid ?? "",

        query: SQLiteQueryParams(
          is_filtered: true,
          where: "clinicKey = ?",
          whereArgs: [clinic_key],
        ),

        voidCallBack: (data) async {
          shiftList = data;

          print("📦 shiftList count: ${data?.length}");

          shiftItems =
              (data ?? [])
                  .whereType<ShiftModel>()
                  .map(
                    (s) => GenericListModel(
                      key: s.key ?? "",
                      name: s.name ?? "فترة",
                    ),
                  )
                  .toList();

          /// ❌ مفيش شيفتات
          if (shiftItems.isEmpty) {
            print("❌ no shifts found");

            selectedShiftModel = null;
            shift_key = null;

            isLoadingShifts = false;
            update();
            return;
          }

          /// 🔥🔥🔥 أهم جزء (fix)
          if (shift_key != null && shift_key!.isNotEmpty) {
            try {
              /// ✅ استخدم الشيفت اللي جاي من الشاشة
              selectedShiftModel = shiftItems.firstWhere(
                (e) => e.key == shift_key,
              );

              print("✅ selected passed shift: $shift_key");
            } catch (_) {
              /// 🔁 fallback لو مش موجود
              selectedShiftModel = shiftItems.first;
              shift_key = selectedShiftModel!.key;

              print("⚠️ passed shift not found → fallback: $shift_key");
            }
          } else {
            /// 🟡 لو مفيش shift جاي
            selectedShiftModel = shiftItems.first;
            shift_key = selectedShiftModel!.key;

            print("🟡 auto selected shift: $shift_key");
          }

          isLoadingShifts = false;
          update();

          /// 🔥 بعد تحديد الشيفت
          final date = companyNameController.text;

          if (date.isNotEmpty && shift_key != null) {
            final formatted =
                date.contains('/') ? normalizeToDashDate(date) : date;

            print("🚀 ready with shift_date: ${shift_key}_$formatted");
          }
        },
      );
    } catch (e) {
      print("❌ loadShifts error: $e");

      isLoadingShifts = false;
      Loader.showError("فشل تحميل الفترات");
      update();
    }
  }

  // Future<int> getNextOrderNumber(String date) async {
  //   int nextOrder = 1;
  //
  //   final doctorUid =
  //       isCenterAssistant
  //           ? selectedDoctor?.uid
  //           : LocalUser().getUserData().doctorKey;
  //
  //   /// ❌ safety
  //   if (doctorUid == null ||
  //       doctorUid.isEmpty ||
  //       clinic_key == null ||
  //       shift_key == null) {
  //     return 1;
  //   }
  //
  //   await ReservationService().getReservationsData(
  //     query: SQLiteQueryParams(
  //       is_filtered: false,
  //
  //       /// 🔥 أهم حاجة هنا
  //       where: """
  //       appointment_date_time = ?
  //       AND clinic_key = ?
  //       AND shift_key = ?
  //       AND doctor_key = ?
  //     """,
  //
  //       whereArgs: [date, clinic_key, shift_key, doctorUid],
  //
  //       /// 🔥 هنجيب آخر رقم
  //       orderBy: "order_num DESC",
  //
  //       /// 🔥 واحد بس
  //       limit: 1,
  //     ),
  //     voidCallBack: (list) {
  //       if (list.isNotEmpty) {
  //         final last = list.first;
  //
  //         final lastOrder = last?.order_num ?? 0;
  //
  //         nextOrder = lastOrder + 1;
  //       } else {
  //         nextOrder = 1;
  //       }
  //     },
  //   );
  //
  //   return nextOrder;
  // }

  Future<void> selectShift(GenericListModel shift) async {
    selectedShiftModel = shift;
    shift_key = shift.key;

    if (companyNameController.text.isEmpty) {
      update();
      return;
    }

    final formatted = companyNameController.text;
    final legacyDate =
        formatted.contains('/') ? normalizeToDashDate(formatted) : formatted;

    // 2️⃣ حمّل حالة اليوم (مفتوح / مغلق)
    await loadOpenCloseStatusForDate(legacyDate);

    await calculateOrderNumber();

    update();
  }

  Future<void> loadLegacyQueueForDate(String date) async {
    final myClinicKey = LocalUser().getUserData().clinicKey;

    if (shift_key == null || shift_key!.isEmpty) return;

    final shiftDate = "${shift_key}_$date";

    final completer = Completer<void>();

    LegacyQueueService().getLegacyQueueByDateData(
      doctorUid: isCenterAssistant ? selectedDoctor?.uid : null,
      firebaseFilter: FirebaseFilter(orderBy: "shift_date", equalTo: shiftDate),
      voidCallBack: (data) async {
        legacyQueueCount = 0;
        currentLegacyQueue = null;

        if (data.isNotEmpty) {
          final item = data.first;

          if (item != null && item.clinic_key == myClinicKey) {
            legacyQueueCount = item.value ?? 0;
            currentLegacyQueue = item;
          }
        }

        update();

        /// 🔥 أهم سطر
        completer.complete();
      },
    );

    return completer.future;
  }

  Future<void> _decreaseLegacyQueue() async {
    if (!isFromLegacyQueue) return;
    if (legacyQueueCount <= 0) return;
    if (currentLegacyQueue == null) return;

    final updatedModel = currentLegacyQueue!.copyWith(
      value: legacyQueueCount - 1,
    );
    Loader.show();

    LegacyQueueService().updateLegacyQueueData(
      model: updatedModel,
      voidCallBack: (_) {
        Loader.dismiss();
        // optional: update local state
        legacyQueueCount = legacyQueueCount - 1;
        update();
      },
    );
  }

  Future<void> onDateChanged(DateTime date) async {
    // 1️⃣ خزّن التاريخ
    create_at = date.millisecondsSinceEpoch;

    final formatted = _toDashFormat(date);
    companyNameController.text = formatted;

    // 2️⃣ حمّل الكشكول للتاريخ الجديد
    await calculateOrderNumber();

    update();
  }

  // void recalculateOrderNum(int nextOrder) {
  //   if (isFromLegacyQueue) {
  //     resOrderController.text = "";
  //   } else {
  //     final finalOrder = legacyQueueCount + nextOrder;
  //     resOrderController.text = finalOrder.toString();
  //   }
  // }

  Future<void> toggleLegacyQueue(bool value) async {
    isFromLegacyQueue = value;

    if (value) {
      /// 🟦 manual (user يكتب الرقم)
      resOrderController.clear();
    } else {
      /// 🟩 رجع للسيستم → احسب order من جديد

      final date = companyNameController.text;

      if (date.isEmpty || shift_key == null) {
        update();
        return;
      }

      final formatted = date.contains('/') ? normalizeToDashDate(date) : date;

      await calculateOrderNumber();
    }

    update();
  }

  void _triggerUpdate() {
    update(); // 🔄 rebuild GetBuilder → recheck validateStep()
  }

  /// ✅ Populate fields when updating reservation
  void populateFields(ReservationModel reservation) {
    _isPopulating = true; // 🔥 stop listeners during loading

    existingReservation = reservation;

    // Patient data
    patientNameController.text = reservation.patientName ?? "";
    patientNameController.text = reservation.patientName ?? "";
    patientPhoneController.text = clientUser?.phone ?? "";
    patientCodeController.text = clientUser?.code ?? "";
    resOrderController.text = reservation.order_num?.toString() ?? "";

    // Payment
    paidAmountController.text = reservation.paidAmount ?? "";
    restAmountController.text = reservation.restAmount ?? "";
    // Type
    selectedType = reservation.reservationType;
    // Date → parse either dd/MM/yyyy or yyyy-MM-dd
    if (reservation.appointmentDateTime != null) {
      try {
        final parsed = DateFormat(
          "dd-MM-yyyy",
        ).parse(normalizeToDashDate(reservation.appointmentDateTime!));

        create_at = parsed.millisecondsSinceEpoch;
      } catch (_) {
        try {
          final parsed = DateFormat(
            "dd-MM-yyyy",
          ).parse(reservation.appointmentDateTime!);
          create_at = parsed.millisecondsSinceEpoch;
        } catch (_) {
          create_at = DateTime.now().millisecondsSinceEpoch;
        }
      }
    }
    // 👇 اضبط سعر الحجز أثناء التعديل من غير تغيير المدفوع
    switch (reservation.reservationType) {
      case "كشف جديد":
        totalAmount = int.tryParse(consultationPrice ?? "0");
        break;
      case "إعادة":
        totalAmount = int.tryParse(followUpPrice ?? "0");
        break;
      case "كشف مستعجل":
        totalAmount = int.tryParse(urgentConsultationPrice ?? "0");
        break;
      default:
        totalAmount = 0;
    }

    // 👇 بعد ضبط totalAmount، احسب الباقي مرة كمان
    _updateRestAmount();

    is_update = true;
    _isPopulating = false; // 🔥 re-enable listeners

    update();
  }

  void _updateRestAmount() {
    if (_isPopulating) return; // 🔥 skip calculation during load

    final paid = int.tryParse(paidAmountController.text) ?? 0;
    final total = totalAmount ?? 0;
    final rest = total - paid;
    restAmountController.text = rest > 0 ? rest.toString() : "0";
    update();
  }

  void setReservationType(String? type) {
    selectedType = type;
    switch (type) {
      case "كشف جديد":
        totalAmount = int.tryParse(consultationPrice ?? "0");
        break;
      case "إعادة":
        totalAmount = int.tryParse(followUpPrice ?? "0");
        break;
      case "كشف مستعجل":
        totalAmount = int.tryParse(urgentConsultationPrice ?? "0");
        break;
      default:
        totalAmount = 0;
    }

    paidAmountController.text = totalAmount?.toString() ?? "0";
    _updateRestAmount();
    update();
  }

  Future<void> _updateClientsSyncStatus() async {
    final ref = FirebaseDatabase.instance.ref("sync_meta/clients");

    await ref.update({
      "last_add_data_timestamp": DateTime.now().millisecondsSinceEpoch,
    });
  }

  void saveReservation(
    List<ReservationModel?> activeList,
    ClinicModel? clinicModel,
  ) async {
    if (isDayClosed) {
      Loader.showError("🚫 هذا اليوم مغلق ولا يمكن الحجز فيه");
      return;
    }

    if (!validateStep()) {
      Loader.showError("⚠️ يرجى ملء جميع الحقول المطلوبة");
      return;
    }

    // 🔹 Ensure patient account exists
    if (clientUser == null) {
      await _createClientAccount();
      if (clientUser == null) {
        Loader.showError("فشل إنشاء حساب المريض");
        return;
      }
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    // ============================================================
    // 🟦 UPDATE MODE
    // ============================================================
    if (is_update && existingReservation != null) {
      final updatedReservation = existingReservation!.copyWith(
        patientKey: clientUser?.key,
        patientUid: clientUser?.uid,
        fcmTokenPatient: clientUser?.fcmToken,

        patientName:
            selectedType == "زيارة مندوب"
                ? delegateNameController.text
                : patientNameController.text,

        patientPhone: patientPhoneController.text,
        reservationType: selectedType,

        appointmentDateTime:
            companyNameController.text.contains('/')
                ? normalizeToDashDate(companyNameController.text)
                : companyNameController.text,

        paidAmount: paidAmountController.text,
        restAmount: restAmountController.text,
        clinicKey: clinic_key,
        shiftKey: shift_key,
        doctorKey:
            isCenterAssistant
                ? selectedDoctor?.uid
                : LocalUser().getUserData().doctorKey,
        medicalCenterKey: LocalUser().getUserData().medicalCenterKey,

        // 🔥 IMPORTANT
        updatedAt: now,
        syncStatus: SyncStatus.pendingUpdate,
      );

      updateReservation(updatedReservation, activeList, clinicModel);
      return;
    }

    // ============================================================
    // 🟩 CREATE MODE
    // ============================================================

    final parsedOrderNum = int.tryParse(resOrderController.text) ?? 0;

    final newReservation = ReservationModel(
      key: const Uuid().v4(),

      doctorKey:
          isCenterAssistant
              ? selectedDoctor?.uid
              : LocalUser().getUserData().doctorKey,
      medicalCenterKey: LocalUser().getUserData().medicalCenterKey,
      doctorName:
          isCenterAssistant
              ? selectedDoctor?.name
              : LocalUser().getUserData().doctorName,

      fcmToken_patient: clientUser?.fcmToken,
      patientKey: clientUser?.key,
      patientUid: clientUser?.uid,

      patientName:
          selectedType == "زيارة مندوب"
              ? delegateNameController.text
              : patientNameController.text,

      patientPhone: patientPhoneController.text,

      assistantKey:
          LocalUser().getUserData().userType?.name == Strings.assistant
              ? LocalUser().getUserData().key
              : null,

      reservationType: selectedType,

      appointmentDateTime:
          companyNameController.text.contains('/')
              ? normalizeToDashDate(companyNameController.text)
              : companyNameController.text,

      paidAmount: paidAmountController.text,
      restAmount: restAmountController.text,

      clinicKey: clinic_key,
      shiftKey: shift_key,
      order_num: parsedOrderNum,

      createAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pendingCreate,
      status: ReservationStatus.approved.value,
    );
    createReservation(newReservation);
  }

  Future<void> getLastReservationDateHuman(LocalUser client) async {
    lastReservationHumanText = null;
    update();

    try {
      final query = SQLiteQueryParams(
        is_filtered: false,
        where: "patient_key = ? AND status = ?",
        whereArgs: [client.key, ReservationStatus.completed.value],
        orderBy: "create_at DESC",
      );

      await ReservationService().getReservationsData(
        query: query,
        voidCallBack: (reservations) {
          if (reservations.isEmpty) {
            lastReservationHumanText = "لا يوجد حجز سابق مكتمل";
            update();
            return;
          }

          final last = reservations.first as ReservationModel;
          lastReservationHumanText = _humanizeDate(last.createAt);
          update();
        },
      );
    } catch (e) {
      lastReservationHumanText = "خطأ في تحميل آخر حجز";
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

  Future<void> getPatientData(ReservationModel reservation) async {
    AuthenticationService().getClientsData(
      query: SQLiteQueryParams(
        where: "key = ?",
        whereArgs: [reservation.patientKey ?? ""],
        limit: 1,
      ),
      voidCallBack: (users) {
        Loader.dismiss();

        if (users.isNotEmpty && users.first != null) {
          clientUser = users.first;
          populateFields(reservation);
        }

        update();
      },
    );
  }

  void updateClinic(ClinicModel clinic) {
    // 🔹 Update clinic data in Firebase
    ClinicService().updateClinicData(
      clinic: clinicModel ?? ClinicModel(),
      voidCallBack: (_) async {
        Get.back();
        Loader.dismiss();
      },
    );
  }

  /// ✅ Create new client in "users"
  Future<void> _createClientAccount() async {
    final phone = patientPhoneController.text.trim();

    if (phone.isEmpty) {
      Loader.showError("رقم الهاتف مطلوب لإنشاء حساب المريض");
      return;
    }

    if (!RegExp(r'^[0-9]{6,15}$').hasMatch(phone)) {
      Loader.showError("يرجى إدخال رقم هاتف صالح (أرقام فقط)");
      return;
    }

    Loader.show();
    final email = "$phone@link.com";
    final password = phone;

    try {
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final uid = userCred.user?.uid ?? "";

      final currentUser = LocalUser().getUserData();

      final newClient = LocalUser(
        key: const Uuid().v4(),
        uid: uid,
        name: patientNameController.text,
        phone: phone,
        identifier: email,
        userType: UserType.patient,
        password: password,
        code: patientCodeController.text,
        doctorKey: currentUser.doctorKey, // ✅ link to current doctor
      );

      await AuthenticationService().addClientsData(
        userclient: newClient,
        voidCallBack: (_) async {
          Loader.dismiss();
          clientUser = newClient; // ✅ NOW we assign it directly here
          _updateClientsSyncStatus();
          update();
        },
      );
    } on FirebaseAuthException catch (e) {
      Loader.showError("فشل إنشاء الحساب: ${e.message}");
      Loader.dismiss();
    } catch (e) {
      Loader.showError("حدث خطأ أثناء إنشاء الحساب");
      Loader.dismiss();
    }
  }

  bool validateStep() {
    // 🟨 حالة زيارة مندوب
    if (selectedType == "زيارة مندوب") {
      return delegateNameController.text.trim().isNotEmpty &&
          companyNameController.text.trim().isNotEmpty;
    }

    final bool phoneValid = patientPhoneController.text.trim().isNotEmpty;
    final bool hasPatientName = patientNameController.text.trim().isNotEmpty;
    final bool hasType = selectedType != null;

    // 🟦 حجز من الكشكول → رقم الكشف إجباري
    if (isFromLegacyQueue) {
      return hasPatientName &&
          hasType &&
          phoneValid &&
          resOrderController.text.trim().isNotEmpty;
    }

    // 🟩 حجز عادي (سيستم)
    return hasPatientName &&
        hasType &&
        phoneValid &&
        paidAmountController.text.trim().isNotEmpty;
  }

  void createReservation(ReservationModel reservation) async {
    Loader.show();

    try {
      // 1️⃣ Add Local (Optimistic)
      await ReservationService().addReservationData(
        reservation: reservation,
        voidCallBack: (_) {
          // 3️⃣ Create patient meta
          createPatientReservation(reservation);
        },
      );
    } catch (e) {
      Loader.dismiss();
      Loader.showError("حدث خطأ أثناء إنشاء الحجز");
    }
  }

  void createPatientReservation(ReservationModel reservation) {
    ReservationService().addPatientReservationMeta(
      patientKey: reservation.patientUid ?? "",
      meta: reservation,
      voidCallBack: (_) async {
        _decreaseLegacyQueue();

        WhatsAppStatusMessageService.sendStatusWhatsAppMessage(
          reservation: reservation,
          clinic: selectedClinic,
          from_assist: true,
          newStatus: ReservationStatus.approved,
        );
        refreshListView();
        //  Get.back();
        Loader.showSuccess("تم إضافة الحجز بنجاح");
      },
    );
  }

  void updateReservation(
    ReservationModel reservation,
    List<ReservationModel?> activeList,
    ClinicModel? clinicModel,
  ) async {
    await ReservationService().updateReservationData(
      reservation: reservation,
      voidCallBack: (_) {},
    );

    // await Get.find<ReservationSyncController>().pushSingleReservation(
    //   reservation,
    // );

    updatePatientReservation(reservation);
  }

  void updatePatientReservation(ReservationModel reservation) {
    ReservationService().updatePatientReservationData(
      key: reservation.patientUid ?? "",
      data: reservation,
      voidCallBack: (_) async {
        //  refreshListView();
        Get.back();
        Loader.showSuccess("تم تحديث الحجز بنجاح");
      },
    );
  }

  void refreshListView() {
    final reservationVM = initController(() => ReservationViewModel());
    reservationVM.fromUpdate = null;
    reservationVM.getReservations();
    reservationVM.update();
    Get.back();
  }

  Future<void> getClinicList(
    ClinicModel? clinicModel,
    ReservationModel reservation,
  ) async {
    consultationPrice = clinicModel?.consultationPrice ?? "";
    followUpPrice = clinicModel?.followUpPrice ?? "";
    urgentConsultationPrice = clinicModel?.urgentConsultationPrice ?? "";
    clinicModel = clinicModel;
    getPatientData(reservation);

    /// 👇 default selected type
    if (selectedType == null && typeOptions.isNotEmpty) {
      selectedType = typeOptions.first;
      setReservationType(selectedType);
    }
  }

  @override
  void dispose() {
    patientCodeController.dispose();
    patientPhoneController.dispose();
    patientNameController.dispose();
    delegateNameController.dispose();
    companyNameController.dispose();
    paidAmountController.dispose();
    restAmountController.dispose();
    resOrderController.dispose();
    super.dispose();
  }
}

String convertArabicToEnglishNumbers(String input) {
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  for (int i = 0; i < arabic.length; i++) {
    input = input.replaceAll(arabic[i], english[i]);
  }
  return input;
}

String _toDashFormat(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date);
}

String normalizeToDashDate(String? date) {
  if (date == null || date.isEmpty) {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  try {
    // dd/MM/yyyy
    if (date.contains('/')) {
      final parsed = DateFormat('dd/MM/yyyy').parse(date);
      return DateFormat('dd-MM-yyyy').format(parsed);
    }

    // yyyy-MM-dd
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
      final parsed = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('dd-MM-yyyy').format(parsed);
    }

    // dd-MM-yyyy (already correct)
    if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(date)) {
      return date;
    }

    // fallback
    final parsed = DateTime.tryParse(date);
    if (parsed != null) {
      return DateFormat('dd-MM-yyyy').format(parsed);
    }

    return date;
  } catch (_) {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }
}
