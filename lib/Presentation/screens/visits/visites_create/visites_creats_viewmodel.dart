import '../../../../../index/index_main.dart';
import 'package:intl/intl.dart';

class CreateVisitViewModel extends GetxController {
  /// Controllers for input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  bool is_update = false;
  VisitModel? existingVisit;

  /// Date picker data
  String? visitDate; // formatted string
  int? selectedDate; // timestamp

  @override
  Future<void> onInit() async {
    super.onInit();

    /// ✅ Set default current date
    final now = DateTime.now();
    visitDate = DateFormat('dd/MM/yyyy').format(now);
    selectedDate = now.millisecondsSinceEpoch;

    /// ✅ Add live listeners to update button state
    nameController.addListener(update);
    addressController.addListener(update);
    phoneController.addListener(update);
    commentController.addListener(update);
  }

  /// ✅ Populate fields with existing visit data
  void populateFields(VisitModel visit) {
    nameController.text = visit.name ?? "";
    addressController.text = visit.address ?? "";
    phoneController.text = visit.phone ?? "";
    commentController.text = visit.comment ?? "";
    is_update = true;
    update();
  }

  /// ✅ Save or update the visit
  void saveVisit() {
    final visit =
        existingVisit?.copyWith(
          name: nameController.text,
          address: addressController.text,
          phone: phoneController.text,
          comment: commentController.text,
        ) ??
        VisitModel(
          key: const Uuid().v4(),
          name: nameController.text,
          address: addressController.text,
          phone: phoneController.text,
          comment: commentController.text,
        );

    is_update ? updateVisit(visit) : createVisit(visit);
  }

  /// ✅ Create a new visit
  void createVisit(VisitModel visit) {
    VisitService().addVisitData(
      visit: visit,
      voidCallBack: (_) {
        refreshListView();
        Loader.showSuccess("تم إنشاء الزيارة بنجاح");
      },
    );
  }

  /// ✅ Update an existing visit
  void updateVisit(VisitModel visit) {
    VisitService().updateVisitData(
      visit: visit,
      voidCallBack: (_) {
        refreshListView();
        Loader.showSuccess("تم تحديث الزيارة بنجاح");
      },
    );
  }

  /// ✅ Refresh visit list after create/update
  void refreshListView() {
    final visitVM = initController(() => VisitViewModel());
    visitVM.getData();
    visitVM.update();
    Get.back();
  }

  /// ✅ Validation function (auto-updated live)
  bool validateStep() {
    return nameController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        visitDate != null;
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    commentController.dispose();
    super.dispose();
  }
}
