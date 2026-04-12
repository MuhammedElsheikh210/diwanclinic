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
  }) {
    clinic_key = clinicKey;
    shift_key = shiftKey;
    total_reservations = totalReservations ?? 0;
    consultationPrice = selectedClinic?.consultationPrice ?? "";
    urgentConsultationPrice = selectedClinic?.urgentConsultationPrice ?? "";
    followUpPrice = selectedClinic?.followUpPrice ?? "";

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
    patientPhoneController.text = reservation.patientKey ?? "";
    //  patientCodeController.text = reservation.patientCode ?? "";
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

  void saveReservation() async {
    if (!validateStep()) {
      Loader.showError("Please fill all required fields");
      return;
    }

    String? formattedDate;
    if (create_at != null) {
      formattedDate = DateFormat(
        "dd-MM-yyyy",
      ).format(DateTime.fromMillisecondsSinceEpoch(create_at!));
    }

    clientUser ??= Get.find<UserSession>().user;


    final reservation =
        existingReservation?.copyWith(
          key: existingReservation?.key,
       //   doctorKey: LocalUser().getUserData().doctorKey,
        //  patientKey: clientUser?.key,
          patientName: selectedType == "زيارة مندوب"
              ? delegateNameController.text
              : patient_name,
          reservationType: selectedType,
          appointmentDateTime: formattedDate,
          createAt: DateTime.now().millisecondsSinceEpoch,
          paidAmount: paidAmountController.text,
          restAmount: restAmountController.text,
          clinicKey: clinic_key,
          shiftKey: shift_key,
          order_num: total_reservations + 1,
          status: ReservationStatus.approved.value,
        ) ??
        ReservationModel(
          key: const Uuid().v4(),
        //  doctorKey: LocalUser().getUserData().doctorKey,
          patientKey: clientUser?.uid,
          createAt: DateTime.now().millisecondsSinceEpoch,
          patientName: selectedType == "زيارة مندوب"
              ? delegateNameController.text
              : patient_name,
          reservationType: selectedType,
          appointmentDateTime: formattedDate,
          clinicKey: clinic_key,
          shiftKey: shift_key,
          paidAmount: paidAmountController.text,
          restAmount: restAmountController.text,
          order_num: total_reservations + 1,
          status: ReservationStatus.approved.value,
        );

    is_update ? updateReservation(reservation) : createReservation(reservation);
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

  void createReservation(ReservationModel reservation) {
    ReservationService().addReservationData(
      reservation: reservation,
      voidCallBack: (_) {
        refreshListView();
        Loader.showSuccess("تم إضافة الحجز بنجاح");
      },
    );
  }

  void updateReservation(ReservationModel reservation) {
    ReservationService().updateReservationData(
      reservation: reservation,
      voidCallBack: (_) {
        refreshListView();
        Loader.showSuccess("تم تحديث الحجز بنجاح");
      },
    );
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
