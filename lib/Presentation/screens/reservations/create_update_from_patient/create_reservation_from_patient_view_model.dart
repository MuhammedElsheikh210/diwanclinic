import 'dart:io';
import 'package:firebase_database/firebase_database.dart' as rtdb;
import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class CreateReservationFromPatientViewModel extends GetxController {
  // Patient info
  final TextEditingController patientCodeController = TextEditingController();
  final TextEditingController patientAddressController =
      TextEditingController();
  final TextEditingController patientPhoneController = TextEditingController();
  final TextEditingController patientNameController = TextEditingController();

  // Delegate fields
  final TextEditingController delegateNameController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();

  // Payment fields
  final TextEditingController paidAmountController = TextEditingController();
  final TextEditingController restAmountController = TextEditingController();

  // Reservation date
  int? create_at = DateTime.now().millisecondsSinceEpoch;

  ReservationModel? existingReservation;
  LocalUser? clientUser;
  bool is_update = false;

  String? clinic_key;
  String? shift_key;
  String? selectedType;
  String? patient_name;
  int total_reservations = 0;

  final List<String> typeOptions = [
    "كشف جديد",
    "كشف مستعجل",
    "إعادة",
    "متابعة",
    "زيارة مندوب",
  ];

  // Prices from Clinic
  String? consultationPrice;
  String? followUpPrice;
  String? urgentConsultationPrice;
  String? appointment_date_time;

  int? totalAmount;

  // 💳 Online Payment
  LocalUser? selectedDoctor;
  String? selectedPaymentMethod; // 'wallet' | 'instapay'
  File? paymentScreenshotFile;
  bool isUploadingScreenshot = false;

  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Any text controller should trigger update on change
    for (var ctrl in [
      patientCodeController,
      patientAddressController,
      patientPhoneController,
      patientNameController,
      delegateNameController,
      companyNameController,
      paidAmountController,
      restAmountController,
    ]) {
      ctrl.addListener(update);
    }
    paidAmountController.addListener(_updateRestAmount);
  }

  /// Called when opening the view
  void initData({
    ReservationModel? reservation,
    String? clinicKey,
    String? shiftKey,
    int? totalReservations,
    ClinicModel? selectedClinic,
    LocalUser? doctor,
  }) {
    clinic_key = clinicKey;
    shift_key = shiftKey;
    total_reservations = totalReservations ?? 0;
    consultationPrice = selectedClinic?.consultationPrice ?? "";
    urgentConsultationPrice = selectedClinic?.urgentConsultationPrice ?? "";
    followUpPrice = selectedClinic?.followUpPrice ?? "";
    selectedDoctor = doctor;

    if (reservation != null) {
      existingReservation = reservation;
      populateFields(reservation);
      is_update = true;
    } else {
      _fillFromLocalUser();
    }
    update();
  }

  /// Fill fields if reservation exists
  void populateFields(ReservationModel reservation) {
    patientNameController.text = reservation.patientName ?? "";
    patientPhoneController.text = reservation.patientUid ?? "";
    patientCodeController.text = reservation.patientCode ?? "";
    //  patientAddressController.text = reservation.patientAddress ?? "";
    selectedType = reservation.reservationType;

    paidAmountController.text = reservation.paidAmount ?? "";
    restAmountController.text = reservation.restAmount ?? "";
    update();
  }

  /// Fill fields from LocalUser (for patient)
  void _fillFromLocalUser() {
     final user = Get.find<UserSession>().user;

    clientUser = user;
    patientNameController.text = user?.name ?? "";
    patientPhoneController.text = user?.phone ?? "";
    patientAddressController.text = user?.address ?? "";
    patientCodeController.text = user?.code ?? "";
    patient_name = user?.name;
  }

  void _updateRestAmount() {
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

  bool get doctorSupportsOnlinePay =>
      selectedDoctor?.asDoctor?.supportsOnlinePay ?? false;

  void selectPaymentMethod(String method) {
    selectedPaymentMethod = method;
    update();
  }

  Future<void> pickPaymentScreenshot() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      paymentScreenshotFile = File(picked.path);
      update();
    }
  }

  Future<String?> _uploadPaymentScreenshot() async {
    if (paymentScreenshotFile == null) return null;
    try {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = FirebaseStorage.instance.ref().child(
        "payment_screenshots/$fileName",
      );
      await ref.putFile(paymentScreenshotFile!);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _deleteUploadedScreenshot(String url) async {
    try {
      await FirebaseStorage.instance.refFromURL(url).delete();
    } catch (_) {}
  }

  String? get _effectiveDoctorKey {
    final user = Get.find<UserSession>().user?.user;
    if (selectedDoctor?.uid != null) return selectedDoctor!.uid;
    if (user is AssistantUser) return user.doctorKey;
    if (user is DoctorUser) return user.uid;
    return null;
  }

  /// Atomically reserves the next unique order number for a given date + shift.
  ///
  /// Uses a Firebase counter at `doctors/{doctorKey}/reservationCounters/{date}_{shiftKey}`
  /// to guarantee uniqueness even when multiple patients book simultaneously.
  /// If the counter is behind the real max (e.g. assistant created reservations),
  /// it fast-forwards the counter before incrementing.
  Future<int> _reserveNextOrderNum({
    required String doctorKey,
    required String date,
    required String shiftKey,
  }) async {
    // Step 1: read real max orderNum from Firebase (handles assistant-created reservations)
    int currentMax = 0;
    try {
      final resRef = rtdb.FirebaseDatabase.instance.ref(
        "doctors/$doctorKey/reservations/$date",
      );
      final resSnapshot = await resRef.get();
      if (resSnapshot.exists && resSnapshot.value != null) {
        final resData = Map<dynamic, dynamic>.from(resSnapshot.value as Map);
        for (final entry in resData.values) {
          if (entry is Map && entry['shiftKey']?.toString() == shiftKey) {
            final n = (entry['order_num'] as num?)?.toInt() ?? 0;
            if (n > currentMax) currentMax = n;
          }
        }
      }
    } catch (_) {}

    // Step 2: atomically increment the counter, clamping below currentMax
    final counterRef = rtdb.FirebaseDatabase.instance.ref(
      "doctors/$doctorKey/reservationCounters/${date}_$shiftKey",
    );

    int reserved = currentMax + 1;
    try {
      final result = await counterRef.runTransaction((Object? current) {
        final c = current == null ? 0 : (current as num).toInt();
        final next = (c > currentMax ? c : currentMax) + 1;
        return rtdb.Transaction.success(next);
      });
      reserved = (result.snapshot.value as num?)?.toInt() ?? reserved;
    } catch (_) {}

    return reserved;
  }

  /// Returns error message if limit reached, null if OK to proceed.
  Future<String?> _checkDayLimit(String formattedDate) async {
    final doctorKey = _effectiveDoctorKey;
    if (doctorKey == null || doctorKey.isEmpty) return null;
    if (shift_key == null || shift_key!.isEmpty) return null;

    try {
      final limitRef = rtdb.FirebaseDatabase.instance.ref(
        "doctors/$doctorKey/dayLimits/${formattedDate}_$shift_key",
      );
      final limitSnapshot = await limitRef.get();
      if (!limitSnapshot.exists || limitSnapshot.value == null) return null;

      final limitData = Map<String, dynamic>.from(limitSnapshot.value as Map);
      final maxCount = (limitData['maxCount'] as num?)?.toInt();
      if (maxCount == null || maxCount <= 0) return null;

      // Count existing reservations for this date + shift from Firebase
      final resRef = rtdb.FirebaseDatabase.instance.ref(
        "doctors/$doctorKey/reservations/$formattedDate",
      );
      final resSnapshot = await resRef.get();

      int count = 0;
      if (resSnapshot.exists && resSnapshot.value != null) {
        final resData = Map<dynamic, dynamic>.from(resSnapshot.value as Map);
        for (final entry in resData.values) {
          if (entry is Map) {
            final resShiftKey = entry['shiftKey']?.toString();
            if (resShiftKey == shift_key) count++;
          }
        }
      }

      if (count >= maxCount) {
        return "عدد الحجوزات اكتملت لهذا اليوم، الحد الأقصى هو $maxCount حجز";
      }
    } catch (e) {
      AppLogger.error("DayLimit", "Error checking day limit", e);
      return null;
    }
    return null;
  }

  void saveReservation() async {
    if (!validateStep()) {
      Loader.showError("يرجى إدخال جميع البيانات المطلوبة");
      return;
    }

    if (doctorSupportsOnlinePay && selectedPaymentMethod == null) {
      Loader.showError("يرجى اختيار طريقة الدفع");
      return;
    }

    if (doctorSupportsOnlinePay && paymentScreenshotFile == null) {
      Loader.showError("يرجى رفع صورة إثبات الدفع");
      return;
    }

    // ── Day limit check (fresh count from Firebase) ──────────────
    if (!is_update && create_at != null) {
      final dateStr = DateFormat(
        "dd-MM-yyyy",
      ).format(DateTime.fromMillisecondsSinceEpoch(create_at!));

      Loader.show();
      final limitError = await _checkDayLimit(dateStr);
      Loader.dismiss();

      if (limitError != null) {
        Loader.showError(limitError);
        return;
      }
    }

    Loader.show();

    String? screenshotUrl;
    if (paymentScreenshotFile != null) {
      screenshotUrl = await _uploadPaymentScreenshot();
      if (screenshotUrl == null) {
        Loader.dismiss();
        Loader.showError("فشل رفع صورة الدفع، يرجى المحاولة مرة أخرى");
        return;
      }
    }

    String? formattedDate;
    if (create_at != null) {
      formattedDate = DateFormat(
        "dd-MM-yyyy",
      ).format(DateTime.fromMillisecondsSinceEpoch(create_at!));
    }

    clientUser ??= Get.find<UserSession>().user;

    // Reserve a unique order number atomically from Firebase
    final doctorKey = _effectiveDoctorKey;
    final int nextOrderNum = (doctorKey != null && formattedDate != null && shift_key != null)
        ? await _reserveNextOrderNum(
            doctorKey: doctorKey,
            date: formattedDate,
            shiftKey: shift_key!,
          )
        : (total_reservations + 1);

    final patientName = selectedType == "زيارة مندوب"
        ? delegateNameController.text
        : patient_name;

    final patientCode = patientCodeController.text.trim().isEmpty
        ? null
        : patientCodeController.text.trim();

    final reservation =
        existingReservation?.copyWith(
          key: existingReservation?.key,
          doctorUid: doctorKey,
          patientName: patientName,
          patientCode: patientCode,
          reservationType: selectedType,
          appointmentDateTime: formattedDate,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          paidAmount: paidAmountController.text,
          restAmount: restAmountController.text,
          clinicKey: clinic_key,
          shiftKey: shift_key,
          orderNum: nextOrderNum,
          status: ReservationStatus.approved.value,
          paymentScreenshotUrl: screenshotUrl,
          paymentMethod: selectedPaymentMethod,
          paymentStatus: screenshotUrl != null ? 'pending_payment' : null,
        ) ??
        ReservationModel(
          key: const Uuid().v4(),
          doctorUid: doctorKey,
          patientUid: clientUser?.uid,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          patientName: patientName,
          patientCode: patientCode,
          reservationType: selectedType,
          appointmentDateTime: formattedDate,
          clinicKey: clinic_key,
          shiftKey: shift_key,
          paidAmount: paidAmountController.text,
          restAmount: restAmountController.text,
          orderNum: nextOrderNum,
          status: ReservationStatus.approved.value,
          paymentScreenshotUrl: screenshotUrl,
          paymentMethod: selectedPaymentMethod,
          paymentStatus: screenshotUrl != null ? 'pending_payment' : null,
        );

    is_update
        ? await updateReservation(reservation)
        : await createReservation(reservation);
  }

  bool validateStep() {
    if (selectedType == "زيارة مندوب") {
      return delegateNameController.text.isNotEmpty &&
          companyNameController.text.isNotEmpty;
    }
    return patient_name != null &&
        selectedType != null &&
        paidAmountController.text.isNotEmpty;
  }

  Future<void> createReservation(ReservationModel reservation) async {
    final uploadedUrl = reservation.paymentScreenshotUrl;
    bool saved = false;

    await ReservationService().addReservationData(
      reservation: reservation,
      voidCallBack: (status) {
        if (status == ResponseStatus.success) saved = true;
      },
    );

    if (!saved) {
      // Rollback: delete orphaned screenshot from Storage
      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        await _deleteUploadedScreenshot(uploadedUrl);
      }
      Loader.dismiss();
      Loader.showError("فشل حفظ الحجز، يرجى المحاولة مرة أخرى");
      return;
    }

    Loader.dismiss();
    refreshListView();
    Loader.showSuccess("تم إضافة الحجز بنجاح");
  }

  Future<void> updateReservation(ReservationModel reservation) async {
    bool saved = false;

    await ReservationService().updateReservationData(
      reservation: reservation,
      voidCallBack: (status) {
        if (status == ResponseStatus.success) saved = true;
      },
    );

    if (!saved) {
      Loader.dismiss();
      Loader.showError("فشل تحديث الحجز، يرجى المحاولة مرة أخرى");
      return;
    }

    Loader.dismiss();
    refreshListView();
    Loader.showSuccess("تم تحديث الحجز بنجاح");
  }

  void refreshListView() {
    final reservationVM = initController(() => ReservationViewModel());
    reservationVM.getReservations();
    reservationVM.update();
    Get.back();
  }

  @override
  void dispose() {
    for (var ctrl in [
      patientCodeController,
      patientAddressController,
      patientPhoneController,
      patientNameController,
      delegateNameController,
      companyNameController,
      paidAmountController,
      restAmountController,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }
}
