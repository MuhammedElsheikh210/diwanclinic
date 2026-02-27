import '../../../../../index/index_main.dart';

class CreateSalesViewModel extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool is_update = false;
  LocalUser? existingSales; // ✅ hold sales being edited

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(() => update());
    phoneController.addListener(() => update());
  }

  /// 🔹 Save sales (either create or update)
  void saveSales() async {
    if (!validateStep()) {
      Loader.showError("يرجى إدخال جميع البيانات بشكل صحيح");
      return;
    }

    if (is_update && existingSales != null) {
      _updateSales(existingSales!);
    } else {
      await _createSalesAccount();
    }
  }

  /// 🔹 Update existing sales
  void _updateSales(LocalUser sales) {
    Loader.show();

    final updatedSales = sales.copyWith(
      name: nameController.text,
      phone: phoneController.text,
      password: phoneController.text, // ✅ password = phone
    );

    AuthenticationService().updateClientsData(
      userclient: updatedSales,
      voidCallBack: (_) {
        Loader.dismiss();
        Loader.showSuccess("تم تحديث مندوب المبيعات بنجاح");
        refreshListView();
      },
    );
  }

  /// 🔹 Create Firebase Auth account for new sales
  Future<void> _createSalesAccount() async {
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
        userType: UserType.sales,
        isCompleteProfile: 1,
        name: nameController.text,
        doctorKey: LocalUser().getUserData().uid,
      );

      _saveSalesToClients(userClient);
    } on FirebaseAuthException catch (e) {
      Loader.showError("فشل إنشاء الحساب: ${e.message}");
    }
  }

  /// 🔹 Save new sales in clients node
  void _saveSalesToClients(LocalUser userClient) {
    AuthenticationService().addClientsData(
      userclient: userClient,
      voidCallBack: (_) {
        Loader.dismiss();
        Loader.showSuccess("تم إضافة مندوب المبيعات بنجاح");
        refreshListView();
      },
    );
  }

  void refreshListView() {
    final salesVM = initController(() => SalesViewModel());
    salesVM.getData();
    salesVM.update();
    Get.back();
  }

  bool validateStep() {
    return nameController.text.isNotEmpty && phoneController.text.isNotEmpty;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
