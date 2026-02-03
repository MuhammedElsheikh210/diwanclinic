import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:diwanclinic/index/index_main.dart';

class PrescriptionPatientBottomSheetWidget extends StatefulWidget {
  final ReservationModel reservation;
  final VoidCallback onUpdated;

  const PrescriptionPatientBottomSheetWidget({
    super.key,
    required this.reservation,
    required this.onUpdated,
  });

  @override
  State<PrescriptionPatientBottomSheetWidget> createState() =>
      _PrescriptionPatientBottomSheetWidgetState();
}

class _PrescriptionPatientBottomSheetWidgetState
    extends State<PrescriptionPatientBottomSheetWidget> {
  File? firstImage;
  File? secondImage;

  @override
  void initState() {
    super.initState();
    _resetLocalFiles();
  }

  @override
  void didUpdateWidget(
    covariant PrescriptionPatientBottomSheetWidget oldWidget,
  ) {
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
        padding: EdgeInsets.only(bottom: 20.h, top: 20, left: 16, right: 16),
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

              _imageSlot(
                context,
                slot: 1,
                localFile: firstImage,
                networkUrl: widget.reservation.prescriptionUrl1,
                onPick: () => _pickImage(1),
                onDelete: () => _deleteImage(1),
              ),
              const SizedBox(height: 12),

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

  // --------------- PICK IMAGE ---------------
  Future<void> _pickImage(int slot) async {
    final picked = await ImagePicker().pickImage(
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

  // --------------- DELETE IMAGE ---------------
  Future<void> _deleteImage(int slot) async {
    try {
      Loader.show();

      final storage = FirebaseStorage.instance;
      String? urlToDelete = slot == 1
          ? widget.reservation.prescriptionUrl1
          : widget.reservation.prescriptionUrl2;

      // delete from storage
      if (urlToDelete != null && urlToDelete.isNotEmpty) {
        await storage.refFromURL(urlToDelete).delete();
      }

      // update model
      if (slot == 1) {
        widget.reservation.prescriptionUrl1 = null;
      } else {
        widget.reservation.prescriptionUrl2 = null;
      }

      // 🔥✨ UPDATE USING: updatePatientReservationData
      await ReservationService().updatePatientReservationData(
        data: widget.reservation,
        key: widget.reservation.key ?? "",
        voidCallBack: (_) => widget.onUpdated(),
      );

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
      Loader.showError("خطأ أثناء الحذف: $e");
    }
  }

  // --------------- UPLOAD IMAGES ---------------
  Future<void> _uploadImages() async {
    try {
      Loader.show();
      final storage = FirebaseStorage.instance;

      Future<File> compress(File file) async {
        try {
          if (!Platform.isAndroid && !Platform.isIOS) return file;

          final dir = await Directory.systemTemp.createTemp();
          final targetPath =
              '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

          final compressed = await FlutterImageCompress.compressAndGetFile(
            file.path,
            targetPath,
            quality: 65,
          );

          return compressed != null ? File(compressed.path) : file;
        } catch (_) {
          return file;
        }
      }

      // upload slot 1
      if (firstImage != null) {
        final c = await compress(firstImage!);
        final ref = storage.ref(
          'prescriptions/${widget.reservation.key}_1_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await ref.putFile(c);
        widget.reservation.prescriptionUrl1 = await ref.getDownloadURL();
      }

      // upload slot 2
      if (secondImage != null) {
        final c = await compress(secondImage!);
        final ref = storage.ref(
          'prescriptions/${widget.reservation.key}_2_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await ref.putFile(c);
        widget.reservation.prescriptionUrl2 = await ref.getDownloadURL();
      }

      // 🔥✨ UPDATE USING: updatePatientReservationData
      await ReservationService().updatePatientReservationData(
        data: widget.reservation,
        key: widget.reservation.key ?? "",
        voidCallBack: (_) => widget.onUpdated(),
      );

      Loader.dismiss();
      Loader.showSuccess("تم رفع الصور بنجاح");
      Get.back();
    } catch (e) {
      Loader.dismiss();
      Loader.showError("حدث خطأ أثناء الرفع: $e");
    }
  }

  Widget _imageSlot(
    BuildContext context, {
    required int slot,
    required File? localFile,
    required String? networkUrl,
    required VoidCallback onPick,
    required VoidCallback onDelete,
  }) {
    final hasImage =
        localFile != null || (networkUrl != null && networkUrl!.isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Text("صورة الروشتة رقم $slot", style: context.typography.mdBold),
          const SizedBox(height: 10),

          /// Image / Placeholder
          GestureDetector(
            onTap: onPick,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 160,
                width: double.infinity,
                color: AppColors.background_neutral_100,
                child: hasImage
                    ? localFile != null
                          ? Image.file(localFile!, fit: BoxFit.cover)
                          : CachedNetworkImage(
                              imageUrl: networkUrl!,
                              fit: BoxFit.cover,
                            )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 36,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "اضغط لاختيار الصورة",
                            style: context.typography.mdMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text("تغيير"),
              ),
              if (hasImage)
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text("حذف"),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.errorForeground,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
