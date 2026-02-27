import '../../../../../index/index_main.dart';
import 'package:intl/intl.dart';

class CreateVisitViewModel extends GetxController {

  /// 🔥 Doctor Snapshot
  DoctorListModel? doctor;

  /// 🔹 Notes
  final TextEditingController commentController = TextEditingController();

  bool isUpdate = false;
  VisitModel? existingVisit;

  /// 🔹 Date & Time
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String? visitDate;      // yyyy-MM-dd
  String? visitTime;      // HH:mm
  int? visitTimestamp;    // millisecondsSinceEpoch

  @override
  void onInit() {
    super.onInit();

    final now = DateTime.now();
    selectedDate = now;
    selectedTime = TimeOfDay.fromDateTime(now);

    _generateDateTimeValues();

    commentController.addListener(update);
  }

  /// 🔥 Initialize from Doctor
  void initFromDoctor(DoctorListModel doc) {
    doctor = doc;
    update();
  }

  /// 🔥 Combine Date + Time → Generate ISO + Timestamp
  void _generateDateTimeValues() {
    if (selectedDate == null || selectedTime == null) return;

    final combined = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    visitTimestamp = combined.millisecondsSinceEpoch;
    visitDate = DateFormat('yyyy-MM-dd').format(combined);
    visitTime = DateFormat('HH:mm').format(combined);
  }

  /// 🔹 When Date Selected (from CalenderWidget)
  void onSelectDate(DateTime date) {
    selectedDate = date;

    // لو الوقت لسه متحددش → خليه دلوقتي
    selectedTime ??= TimeOfDay.fromDateTime(DateTime.now());

    _generateDateTimeValues();
    update();
  }

  /// 🔹 When Time Selected (from TimeWidget)
  void updateTime(TimeOfDay time) {
    selectedTime = time;

    // لو التاريخ لسه متحددش → خليه النهارده
    selectedDate ??= DateTime.now();

    _generateDateTimeValues();
    update();
  }

  /// 🔥 Populate When Editing
  void populateFields(VisitModel visit) {
    existingVisit = visit;
    isUpdate = true;

    commentController.text = visit.comment ?? "";

    if (visit.visitTimestamp != null) {
      final combined =
      DateTime.fromMillisecondsSinceEpoch(visit.visitTimestamp!);

      selectedDate = combined;
      selectedTime = TimeOfDay.fromDateTime(combined);

      _generateDateTimeValues();
    } else if (visit.visitDate != null && visit.visitTime != null) {
      try {
        final combined =
        DateTime.parse("${visit.visitDate} ${visit.visitTime}");

        selectedDate = combined;
        selectedTime = TimeOfDay.fromDateTime(combined);

        _generateDateTimeValues();
      } catch (_) {}
    }

    update();
  }

  /// 🔥 Save Visit
  void saveVisit() {
    if (!validateStep() || doctor == null) return;

    final visit = (existingVisit ??
        VisitModel(key: const Uuid().v4()))
        .copyWith(
      name: doctor!.name,
      specialization: doctor!.specialization,
      doctorClass: doctor!.doctorClass,
      visitDate: visitDate,
      visitTime: visitTime,
      visitTimestamp: visitTimestamp,
      visitStatus: existingVisit?.visitStatus ?? "scheduled",
      comment: commentController.text.trim(),
    );

    isUpdate ? _updateVisit(visit) : _createVisit(visit);
  }

  void _createVisit(VisitModel visit) {
    VisitService().addVisitData(
      visit: visit,
      voidCallBack: (_) {
        Loader.showSuccess("تم إنشاء الزيارة بنجاح");
        Get.back();
      },
    );
  }

  void _updateVisit(VisitModel visit) {
    VisitService().updateVisitData(
      visit: visit,
      voidCallBack: (_) {
        Loader.showSuccess("تم تحديث الزيارة بنجاح");
        Get.back();
      },
    );
  }

  /// 🔥 Validation
  bool validateStep() {
    return visitDate != null &&
        visitTime != null &&
        visitTimestamp != null;
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}