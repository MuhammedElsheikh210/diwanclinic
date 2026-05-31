import '../../../../index/index_main.dart';

class PharmacyDetailViewModel extends GetxController {
  final String pharmacyId;

  PharmacyDetailViewModel({required this.pharmacyId});

  List<LocalUser>? staffList;
  bool isLoading = false;

  LocalUser? get primary {
    if (staffList == null || staffList!.isEmpty) return null;
    return staffList!.firstWhere(
      (u) => u.uid == pharmacyId,
      orElse: () => staffList!.first,
    );
  }

  List<LocalUser> get staffOnly =>
      staffList?.where((u) => u.uid != primary?.uid).toList() ?? [];

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadStaff();
  }

  Future<void> loadStaff() async {
    isLoading = true;
    update();

    // Fetch all pharmacy users then filter client-side — same proven approach as
    // PharmacyViewModel, avoids relying on Firebase index for pharmacy_id.
    List<LocalUser> all = [];
    await AuthenticationService().getClientsOnlineData(
      firebaseFilter: FirebaseFilter(orderBy: "userType", equalTo: "pharmacy"),
      voidCallBack: (users) => all = users,
    );

    staffList = all.where((u) {
      // Include primary account (uid == pharmacyId) regardless of stored pharmacy_id
      if (u.uid == pharmacyId) return true;
      // Include staff accounts whose pharmacy_id points to this pharmacy
      final pid = u.pharmacyId ?? u.uid;
      return pid == pharmacyId;
    }).toList();

    isLoading = false;
    update();
  }

  void deleteMember(LocalUser member) {
    final isOwner = member.uid == pharmacyId;
    showModalBottomSheet(
      context: Get.context!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => ConfirmBottomSheet(
        title: isOwner ? "حذف الصيدلية بالكامل؟" : "حذف الموظف؟",
        message: isOwner
            ? "سيتم حذف حساب الصيدلية الرئيسي. الموظفون الآخرون لن يُحذفوا."
            : "سيتم حذف حساب ${member.name ?? 'هذا الموظف'}.",
        confirmText: "حذف",
        cancelText: "إلغاء",
        onConfirm: () async {
          await AuthenticationService().deleteClientsData(
            uid: member.uid ?? "",
            voidCallBack: (_) async {
              Loader.showSuccess("تم الحذف بنجاح");
              if (isOwner) {
                Get.back();
              } else {
                await loadStaff();
              }
            },
          );
        },
      ),
    );
  }
}
