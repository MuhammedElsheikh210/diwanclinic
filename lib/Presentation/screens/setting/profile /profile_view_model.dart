import 'dart:io';
import 'package:diwanclinic/index/index_main.dart';

class ProfileViewModel extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController(); // ⭐ NEW
  final transferNumberController = TextEditingController();

  File? pickedImage;
  bool isLoading = false;

  int isInstaPay = 0;
  int isElectronicWallet = 0;

  /// Determine user type
  bool get isPatient =>
      Get.find<UserSession>().user?.user.userType == UserType.patient;

  @override
  void onInit() {
    super.onInit();

    final currentUser = Get.find<UserSession>().user;

    if (currentUser == null) {
      
      return;
    }

    final base = currentUser.user;

    nameController.text = base.name ?? "";
    phoneController.text = base.phone ?? "";
    addressController.text = base.address ?? "";

    // ✅ Assistant only
    if (base is AssistantUser) {
      transferNumberController.text = base.transferNumber ?? "";
      isInstaPay = base.isInstaPay ? 1 : 0;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose(); // ⭐ NEW
    transferNumberController.dispose();
    super.dispose();
  }

  /// Pick image (FOR DOCTOR/ASSISTANT ONLY)
  Future<void> pickImage() async {
    if (isPatient) return; // ❌ Patient cannot pick image

    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      pickedImage = File(pickedFile.path);
      update();
    }
  }

  /// Set wallet type (NOT FOR PATIENTS)
  void setWalletType({int? isInstaPay, int? isElectronicWallet}) {
    if (isPatient) return;

    this.isInstaPay = isInstaPay ?? this.isInstaPay;
    this.isElectronicWallet = isElectronicWallet ?? this.isElectronicWallet;
    update();
  }

  /// Upload to Firebase Storage
  Future<String?> _uploadImage(File file, String uid) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(
        "profile_images/$uid.jpg",
      );
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      
      return null;
    }
  }

  /// Update profile in Firebase
  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;

    Loader.show();

    final currentUser = Get.find<UserSession>().user;

    if (currentUser == null) {
      Loader.showError("❌ User not found in session");
      return;
    }

    final base = currentUser.user;
    final uid = base.uid;

    if (uid == null) {
      Loader.showError("User not logged in");
      return;
    }

    // ============================================================
    // 📸 IMAGE
    // ============================================================

    String? imageUrl = base.profileImage;

    if (!isPatient && pickedImage != null) {
      final url = await _uploadImage(pickedImage!, uid);
      if (url != null) imageUrl = url;
    }

    // ============================================================
    // 🧠 BUILD UPDATED USER
    // ============================================================

    BaseUser updatedBase;

    if (base is AssistantUser) {
      updatedBase = AssistantUser(
        uid: base.uid,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        profileImage: imageUrl,

        transferNumber:
            isPatient
                ? base.transferNumber
                : transferNumberController.text.trim(),

        isInstaPay: isPatient ? base.isInstaPay : (isInstaPay == 1),
        doctorKey: base.doctorKey,
        clinicKey: base.clinicKey,
        userType: base.userType,
        isProfileCompleted: base.isProfileCompleted,
      );
    } else {
      updatedBase = base.copyWith(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        profileImage: imageUrl,
      );
    }

    final updatedUser = LocalUser(updatedBase);

    // ============================================================
    // 💾 SAVE
    // ============================================================

    AuthenticationService().updateClientsData(
      userclient: updatedUser,
      voidCallBack: (_) async {
        Loader.dismiss();

        // ✅ update session بدل saveLocal
        await Get.find<UserSession>().updateUser(updatedBase);

        Loader.showSuccess("تم تحديث الملف الشخصي بنجاح");
        Get.back();
      },
    );

    update();
  }
}
