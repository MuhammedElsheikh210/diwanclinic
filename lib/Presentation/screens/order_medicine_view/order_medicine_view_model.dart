import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart'; // 👈 for compute
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../../index/index_main.dart';

class OrderMedicineViewModel extends GetxController {
  final ReservationModel reservation;

  OrderMedicineViewModel(this.reservation);

  // ===============================
  // STEPPER
  // ===============================
  int currentStep = 0;

  // ===============================
  // STEP 1 – UPLOAD
  // ===============================
  static const int maxImages = 5;
  final List<XFile> selectedImages = [];
  final List<String> uploadedUrls = [];
  bool addressError = false;

  final RxDouble uploadProgress = 0.0.obs;
  final RxInt currentUploadIndex = 0.obs;
  final RxBool isUploading = false.obs;

  // ===============================
  // STEP 2 – FORM
  // ===============================
  late TextEditingController phoneController;
  late TextEditingController whatsappController;
  late TextEditingController addressController;
  late TextEditingController doseController;
  late TextEditingController notesController;

  bool isWhatsAppSame = true;
  bool phoneError = false;


  // ===============================
  @override
  void onInit() {
    super.onInit();

    final user = LocalUser().getUserData();
    phoneController = TextEditingController(text: user.phone ?? "");
    whatsappController = TextEditingController(text: user.whatsAppPhone ?? "");
    addressController = TextEditingController(text: user.address ?? "");
    doseController = TextEditingController();
    notesController = TextEditingController();

    // 🔥 اسمع لتغييرات العنوان
    addressController.addListener(() {
      update(); // يعيد بناء الزرار تلقائي
    });

    phoneController.addListener(() {
      update();
    });


    if (whatsappController.text.isEmpty ||
        whatsappController.text == phoneController.text) {
      isWhatsAppSame = true;
      whatsappController.text = phoneController.text;
    } else {
      isWhatsAppSame = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    whatsappController.dispose();
    addressController.dispose();
    doseController.dispose();
    notesController.dispose();
    super.onClose();
  }

  // ===========================================================================
  // 📸 PICK IMAGES
  // ===========================================================================
  Future<void> pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();

    if (picked.isEmpty) return;

    final remain = maxImages - selectedImages.length;
    selectedImages.addAll(picked.take(remain));
    update();
  }

  bool validateForm() {
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();

    phoneError = phone.isEmpty || !_isValidEgyptPhone(phone);
    addressError = address.isEmpty;

    if (phoneError) {
      Loader.showError("يرجى إدخال رقم هاتف صحيح");
    } else if (addressError) {
      Loader.showError("يرجى إدخال عنوان التوصيل");
    }

    update();

    return !phoneError && !addressError;
  }


  bool _isValidEgyptPhone(String phone) {
    final cleaned = phone.trim();

    final regex = RegExp(r'^01[0-2,5]{1}[0-9]{8}$');
    return regex.hasMatch(cleaned);
  }


  void toggleWhatsAppSame(bool? value) {
    isWhatsAppSame = value ?? true;

    if (isWhatsAppSame) {
      whatsappController.text = phoneController.text;
    } else {
      whatsappController.clear();
    }

    update();
  }

  // ===========================================================================
  // ⬆️ UPLOAD IMAGES (OPTIMIZED)
  // ===========================================================================
  // ⬆️ UPLOAD IMAGES (OPTIMIZED + DEBUG)
  // ===========================================================================
  Future<void> uploadImagesAndNext() async {
    if (selectedImages.isEmpty) {
      debugPrint("❌ No images selected");
      return;
    }

    uploadedUrls.clear();
    isUploading.value = true;
    uploadProgress.value = 0;
    currentUploadIndex.value = 0;

    Loader.show();

    final uploadStart = DateTime.now();
    debugPrint("🚀 Upload started at $uploadStart");
    debugPrint("🖼️ Total images: ${selectedImages.length}");

    try {
      for (int i = 0; i < selectedImages.length; i++) {
        currentUploadIndex.value = i + 1;

        final imagePath = selectedImages[i].path;
        final originalFile = File(imagePath);

        final originalSize = (await originalFile.length()) / (1024 * 1024);

        debugPrint("📸 Image ${i + 1}/${selectedImages.length}");
        debugPrint("   ├─ Path: $imagePath");
        debugPrint(
          "   ├─ Original size: ${originalSize.toStringAsFixed(2)} MB",
        );

        // ⏱️ COMPRESS
        final compressStart = DateTime.now();
        final File finalFile = await _compressSmart(originalFile);
        final compressEnd = DateTime.now();

        final compressedSize = (await finalFile.length()) / (1024 * 1024);

        debugPrint(
          "   ├─ Compressed size: ${compressedSize.toStringAsFixed(2)} MB",
        );
        debugPrint(
          "   ├─ Compress time: ${compressEnd.difference(compressStart).inMilliseconds} ms",
        );

        // ⬆️ UPLOAD
        final ref = FirebaseStorage.instance.ref(
          "prescriptions/${reservation.key}_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg",
        );

        debugPrint("   ├─ Uploading to: ${ref.fullPath}");

        final uploadTask = ref.putFile(finalFile);

        uploadTask.snapshotEvents.listen((event) {
          if (event.totalBytes > 0) {
            uploadProgress.value = event.bytesTransferred / event.totalBytes;

            debugPrint(
              "   ├─ Progress: ${(uploadProgress.value * 100).toStringAsFixed(0)}%",
            );
          }
        });

        final uploadStartTime = DateTime.now();
        await uploadTask;
        final uploadEndTime = DateTime.now();

        debugPrint(
          "   ├─ Upload time: ${uploadEndTime.difference(uploadStartTime).inMilliseconds} ms",
        );

        final url = await ref.getDownloadURL();
        uploadedUrls.add(url);

        debugPrint("   └─ ✅ Uploaded URL saved");
      }

      currentStep = 1;
      update();

      final uploadEnd = DateTime.now();
      debugPrint(
        "✅ All uploads finished in ${uploadEnd.difference(uploadStart).inSeconds} seconds",
      );
    } catch (e, s) {
      debugPrint("🔥 Upload error: $e");
      debugPrint("📛 StackTrace: $s");
      Loader.showError("فشل رفع الصور، حاول مرة أخرى");
    } finally {
      isUploading.value = false;
      Loader.dismiss();
    }
  }

  // ===========================================================================
  // 🧠 SMART COMPRESS (SKIP + ISOLATE)
  // ===========================================================================
  // ===========================================================================
  Future<File> _compressSmart(File file) async {
    final sizeMB = await file.length() / (1024 * 1024);

    debugPrint("🧠 Compress check → ${sizeMB.toStringAsFixed(2)} MB");

    if (sizeMB < 1.0) {
      debugPrint("✅ Skip compression (already small)");
      return file;
    }

    final dir = await getTemporaryDirectory();

    final targetPath = p.join(
      dir.path,
      "${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}",
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 55,
      minWidth: 900,
      minHeight: 900,
      format: CompressFormat.jpeg,
    );

    if (result == null) {
      debugPrint("❌ Compression failed → returning original");
      return file;
    }

    debugPrint("✅ Compression done → ${result.path}");
    return File(result.path);
  }

  // 🔥 TOP-LEVEL / STATIC for compute
  static Future<File> _compressImageIsolate(Map<String, String> data) async {
    final path = data['path']!;
    final tempPath = data['tempPath']!;

    final targetPath = p.join(
      tempPath,
      "${DateTime.now().millisecondsSinceEpoch}_${p.basename(path)}",
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      quality: 55,
      minWidth: 900,
      minHeight: 900,
      format: CompressFormat.jpeg,
    );

    if (result == null) {
      debugPrint("❌ Compression failed → returning original");
      return File(path);
    }

    debugPrint("✅ Compression done → ${result.path}");
    return File(result.path);
  }

  // 🔥 TOP-LEVEL / STATIC for compute

  // ===========================================================================
  // 🏥 GET PHARMACY
  // ===========================================================================
  Future<LocalUser> getPharmacyData() async {
    final completer = Completer<LocalUser>();

    await AuthenticationService().getClientsData(
      firebaseFilter: FirebaseFilter(orderBy: "userType", equalTo: "pharmacy"),
      query: SQLiteQueryParams(
        is_filtered: false,
        where: "userType = ?",
        whereArgs: ["pharmacy"],
      ),
      voidCallBack: (users) {
        if (users.isNotEmpty && users.first != null) {
          completer.complete(users.first!);
        } else {
          completer.complete(LocalUser());
        }
      },
    );

    return completer.future;
  }

  // ===========================================================================
  // ✅ CONFIRM ORDER
  // ===========================================================================
  Future<void> confirmOrder(Function(ReservationModel) onConfirmed) async {
    if (!validateForm()) return;

    Loader.show();
    final pharmacy = await getPharmacyData();

    final order = OrderModel(
      key: const Uuid().v4(),
      reservationKey: reservation.key,
      patientuid: reservation.patientUid,
      pharmacyPhone: pharmacy.phone,
      pharmacyFcmToken: pharmacy.fcmToken,
      patientKey: reservation.patientKey,
      doctorKey: reservation.doctorKey,
      fcmToken: reservation.fcmToken_patient,
      doctorName: reservation.doctorName,
      patientName: reservation.patientName,
      clinicKey: reservation.clinicKey,
      createdBy: LocalUser().getUserData().uid,
      phone: phoneController.text.trim(),
      whatsApp: whatsappController.text.trim(),
      address: addressController.text.trim(),
      doseDays: int.tryParse(doseController.text.trim()),
      notes: notesController.text.trim(),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      status: "pending",
      // 📸 Uploaded images
      prescriptionUrl1: uploadedUrls.isNotEmpty ? uploadedUrls[0] : null,
      prescriptionUrl2: uploadedUrls.length > 1 ? uploadedUrls[1] : null,
      prescriptionUrl3: uploadedUrls.length > 2 ? uploadedUrls[2] : null,
      prescriptionUrl4: uploadedUrls.length > 3 ? uploadedUrls[3] : null,
      prescriptionUrl5: uploadedUrls.length > 4 ? uploadedUrls[4] : null,
    );

    OrderService().addOrderData(
      order: order,
      voidCallBack: (res) async {
        if (res != ResponseStatus.success) {
          Loader.showError("حدث خطأ أثناء إرسال الطلب");
          return;
        }

        reservation.isOrdered = true;
        onConfirmed(reservation);

        await NotificationHandler().sendToClinicAssistants(
          title: "💊 طلب روشتة جديد",
          body: "طلب جديد من ${order.patientName}",
          reservation: reservation,
          assistants: [pharmacy],
          notificationType: "new_pharmacy_order",
        );

        Loader.showSuccess("تم إرسال طلب الروشتة بنجاح");
      },
    );
  }
}
