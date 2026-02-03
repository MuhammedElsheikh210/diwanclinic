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
  StreamSubscription<DatabaseEvent>? _firebaseSubscription;

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
  String? selectedType;
  String? patient_name;
  int total_reservations = 0;
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

  @override
  Future<void> onInit() async {
    super.onInit();
    // 🔹 Listen to text controllers for live validation
    patientNameController.addListener(_triggerUpdate);
    resOrderController.addListener(_triggerUpdate);
    patientPhoneController.addListener(_convertPhoneToEnglish);
    patientCodeController.addListener(_triggerUpdate);
    paidAmountController.addListener(_triggerUpdate);
    paidAmountController.addListener(_updateRestAmount);
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

  Future<void> loadLegacyQueueForDate(String date) async {
    final myClinicKey = LocalUser().getUserData().clinicKey;

    LegacyQueueService().getLegacyQueueByDateData(
      date: date,
      voidCallBack: (data) {
        legacyQueueCount = 0;
        currentLegacyQueue = null;

        if (data.isNotEmpty) {
          for (final item in data) {
            if (item == null) continue;

            if (item.clinic_key == myClinicKey) {
              legacyQueueCount = item.value ?? 0;
              currentLegacyQueue = item; // 👈 نخزنه
              break;
            }
          }
        }

        recalculateOrderNum();
        update();
      },
    );
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

    final formatted = DateFormat('dd/MM/yyyy').format(date);
    companyNameController.text = formatted;

    // 2️⃣ حمّل الكشكول للتاريخ الجديد
    await loadLegacyQueueForDate(DateFormat('dd-MM-yyyy').format(date));

    // 3️⃣ احسب عدد حجوزات السيستم في اليوم ده
    total_reservations = await getTotalTodayReservations(formatted);

    // 4️⃣ احسب رقم الحجز
    recalculateOrderNum();

    update();
  }

  void recalculateOrderNum() {
    final int systemCount = total_reservations;
    print("systemCount is ${systemCount}");

    if (isFromLegacyQueue) {
      // 🟦 من الكشكول → إدخال يدوي
      resOrderController.text = "";
    } else {
      // 🟩 حجز سيستم
      resOrderController.text = (systemCount + legacyQueueCount + 1).toString();
    }
  }

  Future<int> getTotalTodayReservations(String date) async {
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
        where: "appointment_date_time = ?",
        whereArgs: [date],
      ),
      voidCallBack: (list) {
        count = list.length;
      },
    );

    return count;
  }

  void toggleLegacyQueue(bool value) {
    isFromLegacyQueue = value;

    if (value) {
      resOrderController.clear(); // 🟦 يدوي
    }

    recalculateOrderNum();
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
          "dd/MM/yyyy",
        ).parse(reservation.appointmentDateTime!);
        create_at = parsed.millisecondsSinceEpoch;
      } catch (_) {
        try {
          final parsed = DateFormat(
            "yyyy-MM-dd",
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

  void saveReservation(
    List<ReservationModel?> activeList,
    ClinicModel? clinicModel,
  ) async {
    if (!validateStep()) {
      Loader.showError("⚠️ يرجى ملء جميع الحقول المطلوبة");
      return;
    }

    // 🔹 Create account if patient does not exist
    if (clientUser == null) {
      await _createClientAccount();
      if (clientUser == null) {
        Loader.showError("فشل إنشاء حساب المريض");
        return;
      }
    }

    ReservationModel reservation;

    // =====================================================================
    // 🟦 UPDATE MODE
    // =====================================================================
    if (is_update && existingReservation != null) {
      reservation = existingReservation!.copyWith(
        // ❗ keep original key / createAt / order_num / status
        patientKey: clientUser?.key,
        patientName: selectedType == "زيارة مندوب"
            ? delegateNameController.text
            : patientNameController.text,
        patientPhone: patientPhoneController.text,
        reservationType: selectedType,
        appointmentDateTime: companyNameController.text,
        paidAmount: paidAmountController.text,
        restAmount: restAmountController.text,
        clinicKey: clinic_key,
        shiftKey: shift_key,
      );

      // updateReservation will trigger refreshListView which re-fetches and reorders
      updateReservation(reservation, activeList, clinicModel);
      return;
    }

    // =====================================================================
    // 🟩 CREATE MODE
    // =====================================================================
    final parsedOrderNum = int.tryParse(resOrderController.text) ?? 0;

    reservation = ReservationModel(
      key: const Uuid().v4(),
      doctorKey: LocalUser().getUserData().doctorKey,
      doctorName: LocalUser().getUserData().doctorName,
      patientKey: clientUser?.key,
      patientUid: clientUser?.uid,
      patientName: selectedType == "زيارة مندوب"
          ? delegateNameController.text
          : patientNameController.text,
      patientPhone: patientPhoneController.text,
      assistantKey:
          LocalUser().getUserData().userType?.name == Strings.assistant
          ? LocalUser().getUserData().key
          : null,
      reservationType: selectedType,
      appointmentDateTime: companyNameController.text,
      paidAmount: paidAmountController.text,
      restAmount: restAmountController.text,
      clinicKey: clinic_key,
      shiftKey: shift_key,
      order_num: parsedOrderNum,
      // ✅ set order_reserved initially same as order_num
      createAt: DateTime.now().millisecondsSinceEpoch,
      status: ReservationStatus.approved.value,
    );

    createReservation(reservation);
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
        data: FirebaseFilter(), // ignored because local
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
    AuthenticationService().getClientsLocalData(
      query: SQLiteQueryParams(
        where: "key = ?",
        whereArgs: [reservation.patientKey ?? ""],
        is_filtered: true,
      ),
      voidCallBack: (user) {
        Loader.dismiss();
        if (user.isNotEmpty) {
          clientUser = user[0];
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

  void createReservation(ReservationModel reservation) {
    ReservationService().addReservationData(
      date: reservation.appointmentDateTime ?? "",
      reservation: reservation,
      voidCallBack: (_) async {
        createPatientReservation(reservation);
      },
    );
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
        Loader.showSuccess("تم إضافة الحجز بنجاح");
      },
    );
  }

  Future<void> checkAndSyncClientsIfNeeded() async {
    final authService = AuthenticationService();
    final user = LocalUser().getUserData();
    final String syncKey = user.uid ?? "";

    if (syncKey.isEmpty) return;

    SyncStatusModel? currentStatus;

    // 1️⃣ Get current sync status
    await authService.getSyncStatus(
      syncModel: SyncStatusModel(key: syncKey),
      voidCallBack: (status) {
        currentStatus = status;
      },
    );

    final int lastAdd = currentStatus?.lastAddDataTimestamp ?? 0;
    final int lastSync = currentStatus?.lastUpdateTimestamp ?? 0;

    // 2️⃣ 🔥 القرار الحقيقي
    if (lastAdd == lastSync) {
      debugPrint("ℹ️ Clients already synced — skip");
      return;
    }

    debugPrint("🔄 Clients out of sync — running FULL clients sync");

    // 3️⃣ FULL CLIENTS SYNC
    await authService.getClientsData(
      isFiltered: false,
      query: SQLiteQueryParams(is_filtered: false),
      voidCallBack: (List<LocalUser?> clients) async {
        debugPrint("✅ Synced ${clients.length} clients locally");
      },
    );

    // 4️⃣ Update sync status (align timestamps)
    final now = DateTime.now().millisecondsSinceEpoch;
    final updated = SyncStatusModel(
      key: syncKey,
      lastAddDataTimestamp: lastAdd, // 👈 نخليها زي ما هي
      lastUpdateTimestamp: now, // 👈 نعلن إننا synced
    );

    await authService.updateSyncStatus(
      model: updated,
      voidCallBack: (_) {
        debugPrint("✅ Sync status aligned");
      },
    );
  }

  void updateReservation(
    ReservationModel reservation,
    List<ReservationModel?> activeList,
    ClinicModel? clinicModel,
  ) {
    ReservationService().updateReservationData(
      date: reservation.appointmentDateTime ?? "",
      reservation: reservation,
      voidCallBack: (_) async {
        updatePatientReservation(reservation);
      },
    );
  }

  void updatePatientReservation(ReservationModel reservation) {
    ReservationService().updatePatientReservationData(
      key: reservation.patientUid ?? "",
      data: reservation,
      voidCallBack: (_) async {
        refreshListView();
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
