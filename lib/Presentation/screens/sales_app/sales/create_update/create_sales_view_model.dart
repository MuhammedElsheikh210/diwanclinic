import '../../../../../index/index_main.dart';

class CreateSalesViewModel extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isUpdate = false;
  LocalUser? existingSales;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(update);
    phoneController.addListener(update);
  }

  // ============================================================
  // 💾 SAVE
  // ============================================================

  void saveSales() async {
    if (!validateStep()) {
      Loader.showError("يرجى إدخال جميع البيانات بشكل صحيح");
      return;
    }

    if (isUpdate && existingSales != null) {
      _updateSales(existingSales!);
    } else {
      await _createSalesAccount();
    }
  }

  // ============================================================
  // ✏️ UPDATE
  // ============================================================

  void _updateSales(LocalUser sales) {
    Loader.show();

    final base = sales.user;

    final updatedBase = base.copyWith(
      name: nameController.text,
      phone: phoneController.text,
      password: phoneController.text,
    );

    final updatedSales = LocalUser(updatedBase);

    AuthenticationService().updateClientsData(
      userclient: updatedSales,
      voidCallBack: (_) {
        Loader.dismiss();
        Loader.showSuccess("تم تحديث مندوب المبيعات بنجاح");
        refreshListView();
      },
    );
  }

  // ============================================================
  // ➕ CREATE
  // ============================================================

  Future<void> _createSalesAccount() async {
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

      // ✅ current user من session
      final currentUser = Get.find<UserSession>().user;

      if (currentUser == null) {
        Loader.dismiss();
        Loader.showError("❌ المستخدم غير موجود");
        return;
      }

      final baseUser = BaseUser(
        uid: uid,
        name: nameController.text,
        phone: phoneController.text,
        identifier: email,
        password: password,
        userType: UserType.sales,
        isProfileCompleted: true,
      );

      final userClient = LocalUser(baseUser);

      _saveSalesToClients(userClient);
    } on FirebaseAuthException catch (e) {
      Loader.dismiss();
      Loader.showError("فشل إنشاء الحساب: ${e.message}");
    }
  }

  // ============================================================
  // 💾 SAVE TO DB
  // ============================================================

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

  // ============================================================
  // 🔄 REFRESH
  // ============================================================

  void refreshListView() {
    final salesVM = initController(() => SalesViewModel());
    salesVM.getData();
    salesVM.update();
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