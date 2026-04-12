import 'dart:io';
import '../../../../index/index_main.dart';

class UploadPrescriptionScreen extends StatefulWidget {
  const UploadPrescriptionScreen({super.key});

  @override
  State<UploadPrescriptionScreen> createState() =>
      _UploadPrescriptionScreenState();
}

class _UploadPrescriptionScreenState extends State<UploadPrescriptionScreen> {
  List<XFile> selectedImages = [];
  static const int maxImages = 5;

  // ---- progress notifiers ----
  final ValueNotifier<double> uploadProgress = ValueNotifier<double>(0.0);
  final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: const HomePatientAppBar(),

        body: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              _topBanner(context),
              SizedBox(height: 30.h),
              _buildUploadArea(context),
              SizedBox(height: 30.h),

              //--------------------------------
              // ACTION BUTTON
              //--------------------------------
              PrimaryTextButton(
                appButtonSize: AppButtonSize.xxLarge,
                customBackgroundColor:
                    selectedImages.isEmpty
                        ? AppColors.buttonDisabledColor
                        : AppColors.primary,
                onTap:
                    selectedImages.isEmpty
                        ? null
                        : () async {
                          await _uploadAllAndOpenSheet(context);
                        },
                label: AppText(
                  text: "طلب الروشتة",
                  textStyle: context.typography.lgBold.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 🔥 1) رفع جميع الصور مرة واحدة مع Progress
  // ===========================================================================
  Future<void> _uploadAllAndOpenSheet(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    text: "جاري رفع الروشتة...",
                    textStyle: context.typography.mdBold.copyWith(
                      color: AppColors.textDisplay,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  ValueListenableBuilder<double>(
                    valueListenable: uploadProgress,
                    builder:
                        (_, value, __) => LinearProgressIndicator(
                          value: value,
                          color: AppColors.primary,
                          backgroundColor: Colors.grey.shade300,
                        ),
                  ),

                  SizedBox(height: 12.h),

                  ValueListenableBuilder<int>(
                    valueListenable: currentIndex,
                    builder:
                        (_, value, __) => AppText(
                          text: "صورة ${value + 1} من ${selectedImages.length}",
                          textStyle: context.typography.smMedium.copyWith(
                            color: AppColors.textSecondaryParagraph,
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ),
    );

    final urls = await uploadPrescriptionImages(selectedImages);

    Navigator.pop(context); // close progress dialog

    if (urls.isEmpty) {
      Loader.showError("فشل الرفع، حاول مرة أخرى");
      return;
    }
    final user = Get.find<UserSession>().user;

    // Build reservation with urls
    final reservation = mapUrlsToReservation(
      ReservationModel(
        patientUid: user?.uid,
        fcmToken_patient: user?.fcmToken,
        patientPhone: user?.phone,
        patientName: user?.name,
      ),
      urls,
    );

    openOrderConfirmationSheet(context: context, reservation: reservation);
  }

  // ===========================================================================
  // 🔥 2) Upload images to Firebase with REAL progress
  // ===========================================================================
  Future<List<String>> uploadPrescriptionImages(List<XFile> images) async {
    List<String> urls = [];

    try {
      for (int i = 0; i < images.length; i++) {
        currentIndex.value = i;
        final file = File(images[i].path);

        final ref = FirebaseStorage.instance.ref().child(
          "prescriptions/${DateTime.now().millisecondsSinceEpoch}_$i.jpg",
        );

        final uploadTask = ref.putFile(file);

        uploadTask.snapshotEvents.listen((taskSnap) {
          double progress = 0.0;

          if (taskSnap.totalBytes > 0) {
            progress = taskSnap.bytesTransferred / taskSnap.totalBytes;
          }

          if (progress.isFinite && !progress.isNaN) {
            uploadProgress.value = progress.clamp(0.0, 1.0);
          }
        });

        await uploadTask;

        final url = await ref.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      return [];
    }
  }

  // ===========================================================================
  // 🔥 3) Map URLs into ReservationModel
  // ===========================================================================
  ReservationModel mapUrlsToReservation(ReservationModel r, List<String> urls) {
    return r.copyWith(
      prescriptionUrl1: urls.length > 0 ? urls[0] : null,
      prescriptionUrl2: urls.length > 1 ? urls[1] : null,
      prescriptionUrl3: urls.length > 2 ? urls[2] : null,
      prescriptionUrl4: urls.length > 3 ? urls[3] : null,
      prescriptionUrl5: urls.length > 4 ? urls[4] : null,
    );
  }

  // ===========================================================================
  // 🔥 UI — Banner
  // ===========================================================================
  Widget _topBanner(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, color: AppColors.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: AppText(
              text: "لو رفعت الروشتة  وطلبتها، هتاخد 10 %  خصم.",
              textStyle: context.typography.mdMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 🔥 UI — Upload Area Grid
  // ===========================================================================
  Widget _buildUploadArea(BuildContext context) {
    if (selectedImages.isEmpty) {
      return GestureDetector(
        onTap: _pickImages,
        child: Container(
          height: 220.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderNeutralPrimary),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file, size: 50.w),
                SizedBox(height: 14.h),
                AppText(
                  text: "اضغط لرفع صور الروشتة",
                  textStyle: context.typography.mdMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: "صور الروشتة (${selectedImages.length}/5)",
            textStyle: context.typography.mdBold,
          ),
          SizedBox(height: 14.h),

          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
            ),
            itemCount:
                selectedImages.length == 5 ? 5 : selectedImages.length + 1,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, index) {
              if (index == selectedImages.length && selectedImages.length < 5) {
                return GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderNeutralPrimary),
                    ),
                    child: Center(child: Icon(Icons.add, size: 32.w)),
                  ),
                );
              }

              final img = selectedImages[index];

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(img.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => selectedImages.removeAt(index));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 🔥 Pick images
  // ===========================================================================
  Future<void> _pickImages() async {
    final picker = ImagePicker();

    if (selectedImages.length >= 5) {
      Loader.showInfo("لا يمكنك رفع أكثر من 5 صور");
      return;
    }

    final picked = await picker.pickMultiImage();
    if (picked != null && picked.isNotEmpty) {
      final remain = 5 - selectedImages.length;
      selectedImages.addAll(picked.take(remain));
      setState(() {});
    }
  }

  // ===========================================================================
  // 🔥 Open confirmation sheet *ONE TIME ONLY*
  // ===========================================================================
  Future<void> openOrderConfirmationSheet({
    required BuildContext context,
    required ReservationModel reservation,
  }) async {
    final user = Get.find<UserSession>().user;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => OrderConfirmationSheet(
            reservation: reservation,
            user: user,
            onConfirmed: (ReservationModel p1) {
              Get.offAll(
                () => const MainPage(initialIndex: 2),
                binding: Binding(),
              );
            },
          ),
    );
  }
}
