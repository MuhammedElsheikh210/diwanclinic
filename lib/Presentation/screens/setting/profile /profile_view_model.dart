import 'dart:io';
import 'package:diwanclinic/Global/managers/location_manager.dart';
import 'package:diwanclinic/index/index_main.dart';

class ProfileViewModel extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Common
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final transferNumberController = TextEditingController();

  // Doctor-specific
  final qualificationsController = TextEditingController();
  final instagramController = TextEditingController();
  final facebookController = TextEditingController();
  final tiktokController = TextEditingController();
  final walletNumberController = TextEditingController();
  final instapayNumberController = TextEditingController();
  final instapayLinkController = TextEditingController();

  bool supportsOnlinePay = false;
  bool requiresDeposit = false;

  // Doctor & Pharmacy
  double? selectedLatitude;
  double? selectedLongitude;
  bool isLoadingLocation = false;

  File? pickedImage;
  bool isLoading = false;

  int isInstaPay = 0;
  int isElectronicWallet = 0;

  bool get isPatient =>
      Get.find<UserSession>().user?.user.userType == UserType.patient;
  bool get isDoctor =>
      Get.find<UserSession>().user?.user.userType == UserType.doctor;
  bool get isPharmacy =>
      Get.find<UserSession>().user?.user.userType == UserType.pharmacy;
  bool get isAssistant =>
      Get.find<UserSession>().user?.user.userType == UserType.assistant;

  @override
  void onInit() {
    super.onInit();

    final currentUser = Get.find<UserSession>().user;
    if (currentUser == null) return;

    final base = currentUser.user;

    nameController.text = base.name ?? "";
    phoneController.text = base.phone ?? "";
    addressController.text = base.address ?? "";

    if (base is AssistantUser) {
      transferNumberController.text = base.transferNumber ?? "";
      isInstaPay = base.isInstaPay ? 1 : 0;
    }

    if (base is DoctorUser) {
      qualificationsController.text = base.doctorQualifications ?? "";
      instagramController.text = base.instagramLink ?? "";
      facebookController.text = base.facebookLink ?? "";
      tiktokController.text = base.tiktokLink ?? "";
      supportsOnlinePay = base.supportsOnlinePay;
      requiresDeposit = base.requiresDeposit;
      walletNumberController.text = base.walletNumber ?? "";
      instapayNumberController.text = base.instapayNumber ?? "";
      instapayLinkController.text = base.instapayLink ?? "";
      selectedLatitude = base.latitude;
      selectedLongitude = base.longitude;
    }

    if (base is PharmacyUser) {
      walletNumberController.text = base.walletNumber ?? "";
      instapayNumberController.text = base.instapayNumber ?? "";
      instapayLinkController.text = base.instapayLink ?? "";
      selectedLatitude = base.latitude;
      selectedLongitude = base.longitude;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    transferNumberController.dispose();
    qualificationsController.dispose();
    instagramController.dispose();
    facebookController.dispose();
    tiktokController.dispose();
    walletNumberController.dispose();
    instapayNumberController.dispose();
    instapayLinkController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    if (isPatient) return;

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

  void setWalletType({int? isInstaPay, int? isElectronicWallet}) {
    if (isPatient) return;
    this.isInstaPay = isInstaPay ?? this.isInstaPay;
    this.isElectronicWallet = isElectronicWallet ?? this.isElectronicWallet;
    update();
  }

  void setSupportsOnlinePay(bool value) {
    supportsOnlinePay = value;
    update();
  }

  void setRequiresDeposit(bool value) {
    requiresDeposit = value;
    update();
  }

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

    String? imageUrl = base.profileImage;

    if (!isPatient && pickedImage != null) {
      final url = await _uploadImage(pickedImage!, uid);
      if (url != null) imageUrl = url;
    }

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
    } else if (base is DoctorUser) {
      updatedBase = base.copyWith(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        profileImage: imageUrl,
        doctorQualifications: qualificationsController.text.trim(),
        instagramLink: instagramController.text.trim(),
        facebookLink: facebookController.text.trim(),
        tiktokLink: tiktokController.text.trim(),
        supportsOnlinePay: supportsOnlinePay,
        requiresDeposit: requiresDeposit,
        walletNumber:
            walletNumberController.text.trim().isEmpty
                ? null
                : walletNumberController.text.trim(),
        instapayNumber:
            instapayNumberController.text.trim().isEmpty
                ? null
                : instapayNumberController.text.trim(),
        instapayLink:
            instapayLinkController.text.trim().isEmpty
                ? null
                : instapayLinkController.text.trim(),
        latitude: selectedLatitude,
        longitude: selectedLongitude,
      );
    } else if (base is PharmacyUser) {
      updatedBase = base.copyWithPharmacy(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        profileImage: imageUrl,
        walletNumber:
            walletNumberController.text.trim().isEmpty
                ? null
                : walletNumberController.text.trim(),
        instapayNumber:
            instapayNumberController.text.trim().isEmpty
                ? null
                : instapayNumberController.text.trim(),
        instapayLink:
            instapayLinkController.text.trim().isEmpty
                ? null
                : instapayLinkController.text.trim(),
        latitude: selectedLatitude,
        longitude: selectedLongitude,
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

    AuthenticationService().updateClientsData(
      userclient: updatedUser,
      voidCallBack: (_) async {
        Loader.dismiss();
        await Get.find<UserSession>().updateUser(updatedBase);
        Loader.showSuccess("تم تحديث الملف الشخصي بنجاح");
        Get.back();
      },
    );

    update();
  }
}
