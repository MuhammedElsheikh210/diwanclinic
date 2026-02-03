import '../../../../../index/index_main.dart';

class CreatePharmacyViewModel extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool is_update = false;
  LocalUser? existingPharmacy; // ✅ hold pharmacy being edited

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(() => update());
    phoneController.addListener(() => update());
  }

  /// 🔹 Save pharmacy (either create or update)
  void savePharmacy() async {
    if (!validateStep()) {
      Loader.showError("يرجى إدخال جميع البيانات بشكل صحيح");
      return;
    }

    if (is_update && existingPharmacy != null) {
      _updatePharmacy(existingPharmacy!);
    } else {
      await _createPharmacyAccount();
    }
  }

  /// 🔹 Update existing pharmacy
  void _updatePharmacy(LocalUser pharmacy) {
    Loader.show();

    final updatedPharmacy = pharmacy.copyWith(
      name: nameController.text,
      phone: phoneController.text,
      password: phoneController.text, // ✅ password = phone
    );

    AuthenticationService().updateClientsData(
      userclient: updatedPharmacy,
      voidCallBack: (_) {
        Loader.dismiss();
        Loader.showSuccess("تم تحديث الصيدلي بنجاح");
        refreshListView();
      },
    );
  }

  /// 🔹 Create Firebase Auth account for new pharmacy
  Future<void> _createPharmacyAccount() async {
    Loader.show();

    final email = "${phoneController.text}@link.com";
    final password = phoneController.text; // ✅ password = phone

    try {
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCred.user?.uid ?? "";

      final userClient = LocalUser(
        uid: uid,
        key: const Uuid().v4(),
        phone: phoneController.text,
        identifier: email,
        password: password,
        userType: UserType.pharmacy, // ✅ pharmacy type
        isCompleteProfile: 1,
        name: nameController.text,
      );

      _savePharmacyToClients(userClient);
    } on FirebaseAuthException catch (e) {
      Loader.showError("فشل إنشاء الحساب: ${e.message}");
    }
  }

  /// 🔹 Save new pharmacy in clients node
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

  void refreshListView() {
    final pharmacyVM = initController(() => PharmacyViewModel());
    pharmacyVM.getData();
    pharmacyVM.update();
    Get.back();
  }

  bool validateStep() {
    return nameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
