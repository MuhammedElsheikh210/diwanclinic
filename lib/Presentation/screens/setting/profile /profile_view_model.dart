import 'dart:io';
import 'package:diwanclinic/index/index_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
      LocalUser().getUserData().userType == UserType.patient;

  @override
  void onInit() {
    super.onInit();
    final user = LocalUser().getUserData();

    nameController.text = user.name ?? "";
    phoneController.text = user.phone ?? "";
    addressController.text = user.address ?? ""; // ⭐ NEW
    transferNumberController.text = user.transferNumber ?? "";

    isInstaPay = user.isInstaPay ?? 0;
    isElectronicWallet = user.isElectronicWallet ?? 0;
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
    this.isElectronicWallet =
        isElectronicWallet ?? this.isElectronicWallet;
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
      debugPrint("Upload failed: $e");
      return null;
    }
  }

  /// Update profile in Firebase
  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;

    Loader.show();
    final user = LocalUser().getUserData();
    final uid = user.uid;

    if (uid == null) {
      Loader.showError("User not logged in");
      return;
    }

    // Upload image ONLY if NOT patient
    String? imageUrl = user.image;
    if (!isPatient && pickedImage != null) {
      final url = await _uploadImage(pickedImage!, uid);
      if (url != null) imageUrl = url;
    }

    // ----------- BUILD UPDATED USER MODEL --------------
    final updatedUser = user.copyWith(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(), // ⭐ SAVE ADDRESS

      // Patient cannot modify these
      image: isPatient ? user.image : imageUrl,
      transferNumber: isPatient
          ? user.transferNumber
          : transferNumberController.text.trim(),
      isInstaPay: isPatient ? user.isInstaPay : isInstaPay,
      isElectronicWallet:
      isPatient ? user.isElectronicWallet : isElectronicWallet,
    );

    // Save to Firebase
    AuthenticationService().updateClientsData(
      userclient: updatedUser,
      voidCallBack: (_) {
        Loader.dismiss();

        // Save locally
        updatedUser.saveLocal(
          saveCallback: () {
            Loader.showSuccess("تم تحديث الملف الشخصي بنجاح");
            Get.back();
          },
        );

        update();
      },
    );
  }
}
