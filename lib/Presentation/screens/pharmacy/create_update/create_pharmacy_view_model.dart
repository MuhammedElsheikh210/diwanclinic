import '../../../../../index/index_main.dart';

class CreatePharmacyViewModel extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isUpdate = false;
  LocalUser? existingPharmacy;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(update);
    phoneController.addListener(update);
  }

  // ============================================================
  // 💾 SAVE
  // ============================================================

  void savePharmacy() async {
    if (!validateStep()) {
      Loader.showError("يرجى إدخال جميع البيانات بشكل صحيح");
      return;
    }

    if (isUpdate && existingPharmacy != null) {
      _updatePharmacy(existingPharmacy!);
    } else {
      await _createPharmacyAccount();
    }
  }

  // ============================================================
  // ✏️ UPDATE
  // ============================================================

  void _updatePharmacy(LocalUser pharmacy) {
    Loader.show();

    final base = pharmacy.user;

    final updatedBaseUser = base.copyWith(
      name: nameController.text,
      phone: phoneController.text,
      password: phoneController.text,
    );

    final updatedPharmacy = LocalUser(updatedBaseUser);

    AuthenticationService().updateClientsData(
      userclient: updatedPharmacy,
      voidCallBack: (_) {
        Loader.dismiss();
        Loader.showSuccess("تم تحديث الصيدلي بنجاح");
        refreshListView();
      },
    );
  }

  // ============================================================
  // ➕ CREATE
  // ============================================================

  Future<void> _createPharmacyAccount() async {
    Loader.show();

    final email = "${phoneController.text}@link.com";
    final password = phoneController.text;

    try {
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user?.uid ?? "";

      final baseUser = BaseUser(
        uid: uid,
        phone: phoneController.text,
        name: nameController.text,
        email: email,
        password: password,
        userType: UserType.pharmacy,
        isProfileCompleted: true,
      );

      final userClient = LocalUser(baseUser);

      _savePharmacyToClients(userClient);
    } on FirebaseAuthException catch (e) {
      Loader.dismiss();
      Loader.showError("فشل إنشاء الحساب: ${e.message}");
    }
  }

  // ============================================================
  // 💾 SAVE TO DB
  // ============================================================

  void _savePharmacyToClients(LocalUser userClient) {
    AuthenticationService().addClientsData(
      userclient: userClient,
      voidCallBack: (_) {
        Loader.dismiss();
        Loader.showSuccess("تم إضافة الصيدلي بنجاح");
        refreshListView();
      },
    );
  }

  // ============================================================
  // 🔄 REFRESH
  // ============================================================

  void refreshListView() {
    final pharmacyVM = initController(() => PharmacyViewModel());
    pharmacyVM.getData();
    pharmacyVM.update();
    Get.back();
  }

  // ============================================================
  // ✅ VALIDATION
  // ============================================================

  bool validateStep() {
    return nameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty;
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}