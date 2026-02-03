import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:diwanclinic/Data/Models/User_local/save_local_user.dart';
import 'package:diwanclinic/Data/Models/User_local/user_types_enums.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../index/index_main.dart';
import '../list/doctor_view_model.dart';

class CreateDoctorViewModel extends GetxController {
  final String specializeKey;
  final String specializeName;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController tiktokController = TextEditingController();
  final TextEditingController specializationNameController = TextEditingController();

  File? profileImageFile;
  File? coverImageFile;

  /// NEW FIELD → Remote reservation ability (0 off, 1 on)
  int remoteReservationAbility = 0;

  bool isUpdate = false;
  LocalUser? existingDoctor;

  CreateDoctorViewModel({
    required this.specializeKey,
    required this.specializeName,
  });

  final _picker = ImagePicker();

  /// 🔹 Pick Profile Image
  Future<void> pickProfileImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      profileImageFile = File(picked.path);
      update();
    }
  }

  /// 🔹 Pick Cover Image
  Future<void> pickCoverImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      coverImageFile = File(picked.path);
      update();
    }
  }

  /// 🔹 Upload Image
  Future<String?> _uploadImage(File file, String folder) async {
    try {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = FirebaseStorage.instance.ref().child("doctors/$folder/$fileName");
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("❌ Failed to upload image: $e");
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(() => update());
    phoneController.addListener(() => update());

    /// If doctor exists (EDIT MODE), load remote reservation ability
    if (existingDoctor != null) {
      remoteReservationAbility = existingDoctor?.remote_reservation_ability ?? 0;
    }
  }

  /// 🔹 Toggle remote ability (used from UI switch)
  void setRemoteReservationAbility(bool value) {
    remoteReservationAbility = value ? 1 : 0;
    update();
  }

  /// 🔹 Save doctor (create/update)
  Future<void> saveDoctor() async {
    if (!validateStep()) {
      Loader.showError("يرجى إدخال جميع البيانات بشكل صحيح");
      return;
    }

    Loader.show();

    String? profileUrl;
    String? coverUrl;

    if (profileImageFile != null) {
      profileUrl = await _uploadImage(profileImageFile!, "profile");
    }
    if (coverImageFile != null) {
      coverUrl = await _uploadImage(coverImageFile!, "cover");
    }

    if (isUpdate && existingDoctor != null) {
      _updateDoctor(existingDoctor!, profileUrl, coverUrl);
    } else {
      await _createDoctorAccount(profileUrl, coverUrl);
    }
  }

  /// 🔹 Update existing doctor
  void _updateDoctor(LocalUser doctor, String? profileUrl, String? coverUrl) {
    final updatedDoctor = doctor.copyWith(
      name: nameController.text,
      phone: phoneController.text,
      whatsAppPhone: whatsappController.text,
      facebookLink: facebookController.text,
      instagramLink: instagramController.text,
      tiktokLink: tiktokController.text,
      specializationName: specializationNameController.text,
      profileImage: profileUrl ?? doctor.profileImage,
      coverImage: coverUrl ?? doctor.coverImage,
      remote_reservation_ability: remoteReservationAbility, // NEW
    );

    AuthenticationService().updateClientsData(
      userclient: updatedDoctor,
      voidCallBack: (_) {
        Loader.dismiss();
        Loader.showSuccess("تم تحديث الطبيب بنجاح");
        refreshListView();
      },
    );
  }

  /// 🔹 Create new doctor account
  Future<void> _createDoctorAccount(String? profileUrl, String? coverUrl) async {
    final email = "${phoneController.text}@link.com";
    final password = phoneController.text;

    try {
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCred.user?.uid ?? "";

      final doctor = LocalUser(
        uid: uid,
        key: const Uuid().v4(),
        phone: phoneController.text,
        whatsAppPhone: whatsappController.text,
        facebookLink: facebookController.text,
        instagramLink: instagramController.text,
        tiktokLink: tiktokController.text,
        specializationName: specializationNameController.text,
        identifier: email,
        password: password,
        userType: UserType.doctor,
        specialize_key: specializeKey,
        profileImage: profileUrl,
        coverImage: coverUrl,
        isCompleteProfile: 0,
        name: nameController.text,
        remote_reservation_ability: remoteReservationAbility, // NEW
      );

      AuthenticationService().addClientsData(
        userclient: doctor,
        voidCallBack: (_) {
          Loader.dismiss();
          Loader.showSuccess("تم إضافة الطبيب بنجاح");
          refreshListView();
        },
      );
    } on FirebaseAuthException catch (e) {
      Loader.showError("فشل إنشاء الحساب: ${e.message}");
    }
  }

  void refreshListView() {
    final doctorVM = initController(
          () => DoctorViewModel(specializeKey: specializeKey),
    );
    doctorVM.getData();
    doctorVM.update();
    Get.back();
  }

  bool validateStep() {
    return nameController.text.isNotEmpty && phoneController.text.isNotEmpty;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    whatsappController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    tiktokController.dispose();
    specializationNameController.dispose();
    super.dispose();
  }
}
