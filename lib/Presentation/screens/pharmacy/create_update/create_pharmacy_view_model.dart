import 'package:diwanclinic/Global/managers/location_manager.dart';
import '../../../../../index/index_main.dart';

class CreatePharmacyViewModel extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController walletController = TextEditingController();
  final TextEditingController instapayNumberController = TextEditingController();
  final TextEditingController instapayLinkController = TextEditingController();

  double? selectedLatitude;
  double? selectedLongitude;
  bool isLoadingLocation = false;

  bool isUpdate = false;
  LocalUser? existingPharmacy;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(update);
    phoneController.addListener(update);
  }

  // ============================================================
  // 📍 LOCATION
  // ============================================================

  Future<void> fetchCurrentLocation() async {
    isLoadingLocation = true;
    update();
    final latLng = await LocationManager().getLatLng();
    if (latLng != null) {
      selectedLatitude = latLng['lat'];
      selectedLongitude = latLng['lng'];
    }
    isLoadingLocation = false;
    update();
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

    final existing = pharmacy.asPharmacy;

    final updated = PharmacyUser(
      uid: existing?.uid ?? pharmacy.user.uid,
      createdAt: existing?.createdAt ?? pharmacy.user.createdAt,
      userType: UserType.pharmacy,
      isProfileCompleted: true,
      fcmToken: existing?.fcmToken ?? pharmacy.user.fcmToken,
      appVersion: existing?.appVersion ?? pharmacy.user.appVersion,
      identifier: existing?.identifier ?? pharmacy.user.identifier,
      code: existing?.code ?? pharmacy.user.code,
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      password: phoneController.text.trim(),
      latitude: selectedLatitude,
      longitude: selectedLongitude,
      walletNumber: walletController.text.trim().isEmpty
          ? null
          : walletController.text.trim(),
      instapayNumber: instapayNumberController.text.trim().isEmpty
          ? null
          : instapayNumberController.text.trim(),
      instapayLink: instapayLinkController.text.trim().isEmpty
          ? null
          : instapayLinkController.text.trim(),
    );

    AuthenticationService().updateClientsData(
      userclient: LocalUser(updated),
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
    final password = phoneController.text.trim();

    try {
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCred.user?.uid ?? "";

      final pharmacyUser = PharmacyUser(
        uid: uid,
        phone: password,
        name: nameController.text.trim(),
        identifier: email,
        password: password,
        userType: UserType.pharmacy,
        isProfileCompleted: true,
        latitude: selectedLatitude,
        longitude: selectedLongitude,
        walletNumber: walletController.text.trim().isEmpty
            ? null
            : walletController.text.trim(),
        instapayNumber: instapayNumberController.text.trim().isEmpty
            ? null
            : instapayNumberController.text.trim(),
        instapayLink: instapayLinkController.text.trim().isEmpty
            ? null
            : instapayLinkController.text.trim(),
      );

      _savePharmacyToClients(LocalUser(pharmacyUser));
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
    return nameController.text.isNotEmpty && phoneController.text.isNotEmpty;
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    walletController.dispose();
    instapayNumberController.dispose();
    instapayLinkController.dispose();
    super.dispose();
  }
}
