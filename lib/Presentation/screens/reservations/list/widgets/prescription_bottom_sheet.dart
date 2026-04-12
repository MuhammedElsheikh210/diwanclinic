import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../../../index/index_main.dart';

class PrescriptionBottomSheetWidget extends StatefulWidget {
  final ReservationModel reservation;
  final VoidCallback onUpdated;

  const PrescriptionBottomSheetWidget({
    super.key,
    required this.reservation,
    required this.onUpdated,
  });

  @override
  State<PrescriptionBottomSheetWidget> createState() =>
      _PrescriptionBottomSheetWidgetState();
}

class _PrescriptionBottomSheetWidgetState
    extends State<PrescriptionBottomSheetWidget> {
  File? firstImage;
  File? secondImage;

  @override
  void initState() {
    super.initState();
    _resetLocalFiles();
  }

  @override
  void didUpdateWidget(covariant PrescriptionBottomSheetWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reservation.key != widget.reservation.key) {
      _resetLocalFiles();
    }
  }

  void _resetLocalFiles() {
    firstImage = null;
    secondImage = null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              AppText(
                text: "إدارة صور الروشتة",
                textStyle: context.typography.lgBold,
              ),
              const SizedBox(height: 20),

              // Slot 1
              _imageSlot(
                context,
                slot: 1,
                localFile: firstImage,
                networkUrl: widget.reservation.prescriptionUrl1,
                onPick: () => _pickImage(1),
                onDelete: () => _deleteImage(1),
              ),
              const SizedBox(height: 12),

              // Slot 2
              _imageSlot(
                context,
                slot: 2,
                localFile: secondImage,
                networkUrl: widget.reservation.prescriptionUrl2,
                onPick: () => _pickImage(2),
                onDelete: () => _deleteImage(2),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: ScreenUtil().screenWidth,
                height: 55.h,
                child: PrimaryTextButton(
                  label: AppText(
                    text: "رفع / تحديث الصور",
                    textStyle: context.typography.mdBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  appButtonSize: AppButtonSize.large,
                  onTap: _uploadImages,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🟢 Pick image for specific slot
  Future<void> _pickImage(int slot) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        if (slot == 1) {
          firstImage = File(picked.path);
        } else {
          secondImage = File(picked.path);
        }
      });
    }
  }

  // 🟢 Delete image for specific slot
  Future<void> _deleteImage(int slot) async {
    try {
      Loader.show();
      final storage = FirebaseStorage.instance;

      String? urlToDelete;
      final reservationKey = widget.reservation.key ?? "";

      if (slot == 1) {
        urlToDelete = widget.reservation.prescriptionUrl1;
      } else {
        urlToDelete = widget.reservation.prescriptionUrl2;
      }

      // 🔹 Delete from Firebase Storage if exists
      if (urlToDelete != null && urlToDelete.isNotEmpty) {
        await storage.refFromURL(urlToDelete).delete();
      }

      // 🔹 Update local model
      if (slot == 1) {
        widget.reservation.prescriptionUrl1 = null;
      } else {
        widget.reservation.prescriptionUrl2 = null;
      }

      // ✅ Update directly in Firebase Realtime Database

      final currentUser = Get.find<UserSession>().user;

      if (currentUser == null || !currentUser.isAssistant) {
        debugPrint("❌ Current user is not assistant");
        return;
      }

      final assistant = currentUser.asAssistant;

      if (assistant == null) {
        debugPrint("❌ Failed to cast to AssistantUser");
        return;
      }

      final doctorKey = assistant.doctorKey ?? "";

      final DatabaseReference ref = FirebaseDatabase.instance.ref(
        "doctors/$doctorKey/reservations/$reservationKey",
      );

      await ref.update({
        if (slot == 1)
          "prescription_url_1": null
        else
          "prescription_url_2": null,
      });

      widget.onUpdated();

      Loader.dismiss();
      Loader.showSuccess("تم حذف الصورة بنجاح");

      setState(() {
        if (slot == 1) {
          firstImage = null;
        } else {
          secondImage = null;
        }
      });
    } catch (e) {
      Loader.dismiss();
      Loader.showError("حدث خطأ أثناء حذف الصورة: $e");
    }
  }

  // 🟢 Upload new images (with safe compression)
  Future<void> _uploadImages() async {
    try {
      Loader.show();
      final storage = FirebaseStorage.instance;

      Future<File> compressImageSafe(File file, String name) async {
        try {
          // ✅ Skip compression if not supported (e.g. simulator)
          if (!Platform.isAndroid && !Platform.isIOS) {
            return file;
          }

          final dir = await Directory.systemTemp.createTemp();
          final targetPath = '${dir.path}/$name.jpg';

          final XFile? compressedXFile =
              await FlutterImageCompress.compressAndGetFile(
                file.absolute.path,
                targetPath,
                quality: 65,
                format: CompressFormat.jpeg,
              );

          return compressedXFile != null ? File(compressedXFile.path) : file;
        } catch (e) {
          debugPrint("⚠️ Compression skipped: $e");
          return file;
        }
      }

      // 🔹 Slot 1
      if (firstImage != null) {
        final compressed = await compressImageSafe(
          firstImage!,
          "prescription_1_${DateTime.now().millisecondsSinceEpoch}",
        );

        final ref1 = storage.ref(
          'prescriptions/${widget.reservation.key}_1_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await ref1.putFile(compressed);
        widget.reservation.prescriptionUrl1 = await ref1.getDownloadURL();
      }

      // 🔹 Slot 2
      if (secondImage != null) {
        final compressed = await compressImageSafe(
          secondImage!,
          "prescription_2_${DateTime.now().millisecondsSinceEpoch}",
        );

        final ref2 = storage.ref(
          'prescriptions/${widget.reservation.key}_2_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await ref2.putFile(compressed);
        widget.reservation.prescriptionUrl2 = await ref2.getDownloadURL();
      }

      await ReservationService().updateReservationData(
        reservation: widget.reservation,
        voidCallBack: (_) => widget.onUpdated(),
      );

      Loader.dismiss();
      Loader.showSuccess("تم رفع الصور بنجاح (مع ضغط الحجم)");
      Get.back();
    } catch (e) {
      Loader.dismiss();
      Loader.showError("حدث خطأ أثناء الرفع: $e");
    }
  }

  // 🟢 Build image upload slot
  Widget _imageSlot(
    BuildContext context, {
    required int slot,
    required File? localFile,
    required String? networkUrl,
    required VoidCallback onPick,
    required VoidCallback onDelete,
  }) {
    final hasValidUrl =
        networkUrl != null && networkUrl.isNotEmpty && networkUrl != "null";
    final hasLocal = localFile != null;

    final bool showNetworkImage = hasValidUrl && !hasLocal;
    final bool showLocalImage = hasLocal && !hasValidUrl;

    final bool hasImage = showNetworkImage || showLocalImage;

    return Container(
      height: 160.h,
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background_neutral_100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderNeutralPrimary),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasImage)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    showNetworkImage
                        ? CachedNetworkImage(
                          imageUrl: networkUrl!,
                          fit: BoxFit.cover,
                          errorWidget:
                              (_, __, ___) => const Icon(
                                Icons.broken_image,
                                color: AppColors.errorForeground,
                              ),
                        )
                        : Image.file(localFile!, fit: BoxFit.cover),
              ),
            )
          else
            Expanded(
              child: InkWell(
                onTap: onPick,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_file, color: AppColors.primary),
                    const SizedBox(height: 6),
                    Text(
                      "اختر الصورة رقم $slot",
                      style: context.typography.mdMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.edit, color: AppColors.primary),
                label: const Text(
                  "تغيير",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              if (hasImage)
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete,
                    color: AppColors.errorForeground,
                  ),
                  label: const Text(
                    "حذف",
                    style: TextStyle(color: AppColors.errorForeground),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
