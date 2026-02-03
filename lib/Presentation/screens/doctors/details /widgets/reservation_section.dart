import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:diwanclinic/Presentation/Widgets/drop_down/adatper/clinic_adapter.dart';
import 'clinic_info_widget.dart';
import '../../../../../index/index_main.dart';

class SelectReservationDateBottomSheet extends StatefulWidget {
  final DoctorDetailsViewModel controller;
  final String transfer_phone;
  final int wallet_type;

  const SelectReservationDateBottomSheet({
    required this.controller,
    required this.transfer_phone,
    required this.wallet_type,
    super.key,
  });

  @override
  State<SelectReservationDateBottomSheet> createState() =>
      _SelectReservationDateBottomSheetState();
}

class _SelectReservationDateBottomSheetState
    extends State<SelectReservationDateBottomSheet> {
  File? _screenshotFile;
  bool _isUploading = false;

  // 🟢 Pick image (from gallery)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _screenshotFile = File(picked.path));
    }
  }

  // 🟢 Upload screenshot
  Future<String?> _uploadScreenshot() async {
    if (_screenshotFile == null) return null;

    try {
      setState(() => _isUploading = true);
      Loader.show();

      // Compress if > 1MB
      final int originalSize = await _screenshotFile!.length();
      File fileToUpload = _screenshotFile!;
      final sizeInMB = originalSize / (1024 * 1024);
      if (sizeInMB > 1.0) {
        final tempDir = Directory.systemTemp;
        final targetPath =
            "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
        final XFile? compressed = await FlutterImageCompress.compressAndGetFile(
          _screenshotFile!.path,
          targetPath,
          quality: sizeInMB > 5 ? 60 : 75,
        );
        if (compressed != null) fileToUpload = File(compressed.path);
      }

      // Upload
      final ref = FirebaseStorage.instance.ref(
        "transfer_screenshots/${DateTime.now().millisecondsSinceEpoch}.jpg",
      );
      await ref.putFile(fileToUpload);
      final url = await ref.getDownloadURL();

      Loader.dismiss();
      Loader.showSuccess("تم رفع الصورة بنجاح");
      return url;
    } catch (e) {
      Loader.dismiss();
      Loader.showError("حدث خطأ أثناء رفع الصورة");
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // 🟢 Validation
  bool _validate(
    DoctorDetailsViewModel controller, {
    bool checkScreenshot = false,
  }) {
    if (controller.selectedClinic == null) {
      Loader.showError("من فضلك اختر العيادة");
      return false;
    }
    if (controller.selectedShift == null) {
      Loader.showError("من فضلك اختر الفترة");
      return false;
    }
    if (controller.selectedReservationType == null) {
      Loader.showError("من فضلك اختر نوع الحجز");
      return false;
    }
    if (controller.selectedDate == null) {
      Loader.showError("من فضلك اختر التاريخ");
      return false;
    }
    if (checkScreenshot && _screenshotFile == null) {
      Loader.showError("برجاء رفع صورة التحويل قبل تأكيد الحجز");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final typography = context.typography;

    final clinic = controller.selectedClinic;
    double selectedPrice = 0.0;
    if (clinic != null) {
      switch (controller.selectedReservationType) {
        case "كشف مستعجل":
          selectedPrice =
              double.tryParse(clinic.urgentConsultationPrice ?? "0") ?? 0.0;
          break;
        case "إعادة":
          selectedPrice = double.tryParse(clinic.followUpPrice ?? "0") ?? 0.0;
          break;
        default:
          selectedPrice =
              double.tryParse(clinic.consultationPrice ?? "0") ?? 0.0;
      }
    }

    final depositPercent = clinic?.minimumDepositPercent ?? 0.0;
    final depositAmount = (selectedPrice * depositPercent) / 100;
    final requiresDeposit =
        clinic?.reserveWithDeposit == 1 &&
        depositPercent > 0 &&
        selectedPrice > 0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
      child: GetBuilder<DoctorDetailsViewModel>(
        init: controller,
        builder: (_) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 Title
                Text(
                  "تأكيد الحجز",
                  style: typography.xlBold.copyWith(
                    color: AppColors.textDisplay,
                  ),
                ),
                SizedBox(height: 16.h),

                // 🔹 رقم الكشف (Order number)
                if (controller.nextOrder != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary10,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.primary40),
                    ),
                    child: Text(
                      "رقم الكشف: ${controller.nextOrder}",
                      style: typography.lgBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                // 🔹 Clinic & Shift Section (dropdowns + info)
                ClinicAndShiftSection(
                  controller: controller,
                  showFromHome: true,
                  showClinicInfo: false,
                ),

                SizedBox(height: 20.h),

                // 🔹 Deposit Section
                if (requiresDeposit) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary10,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.primary40),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "💳 للحجز يجب دفع ${depositPercent.toStringAsFixed(0)}% من سعر (${controller.selectedReservationType ?? "الكشف"}) ≈ ${depositAmount.toStringAsFixed(2)} ج.م",
                          style: typography.mdMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "📲 يُرجى تحويل المبلغ إلى الرقم التالي:",
                          style: typography.smRegular.copyWith(
                            color: AppColors.textSecondaryParagraph,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "${widget.transfer_phone}   ${widget.wallet_type == 0 ? "محفظة إلكترونية" : "إنستا باي"}",
                          style: typography.mdBold.copyWith(
                            color: AppColors.textDisplay,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "ثم أرسل صورة التحويل لتأكيد الحجز.",
                          style: typography.smRegular.copyWith(
                            color: AppColors.textSecondaryParagraph,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🔹 Screenshot Upload
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.background_neutral_100,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: AppColors.borderNeutralPrimary,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_screenshotFile != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.file(
                                _screenshotFile!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 150.h,
                              ),
                            )
                          else
                            Column(
                              children: [
                                const Icon(
                                  Icons.upload_file,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "قم برفع لقطة شاشة من التحويل",
                                  style: typography.mdMedium.copyWith(
                                    color: AppColors.textSecondaryParagraph,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // 🔹 Calendar
                CalenderWidget(
                  onDateSelected: (timeStamp, date) {
                    final pickedDate = DateTime.fromMillisecondsSinceEpoch(
                      timeStamp.millisecondsSinceEpoch,
                    );
                    controller.onSelectDate(pickedDate);
                  },
                  initialTimestamp: controller.selectedDate != null
                      ? controller.selectedDate!.millisecondsSinceEpoch
                      : DateTime.now().millisecondsSinceEpoch,
                  hintText: "اختر تاريخ الحجز",
                ),

                SizedBox(height: 10.h),

                if (controller.isLoadingOrderInfo)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: const CircularProgressIndicator(),
                  )
                else if (controller.beforeYouCount != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    margin: EdgeInsets.only(top: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary10,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.primary40),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "👥 هيكون قبلك ${controller.beforeYouCount} حالة ",
                          style: typography.mdBold.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "📌 دورك رقم ${controller.expectedOrder}",
                          style: typography.smRegular.copyWith(
                            color: AppColors.textSecondaryParagraph,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20.h),

                // 🔹 Confirm Button
                SizedBox(
                  width: ScreenUtil().screenWidth,
                  child: PrimaryTextButton(
                    appButtonSize: AppButtonSize.xxLarge,
                    label: AppText(
                      text: _isUploading ? "جاري الرفع..." : "تأكيد الحجز",
                      textStyle: typography.mdBold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    onTap: () async {
                      final valid = _validate(
                        controller,
                        checkScreenshot: requiresDeposit,
                      );
                      if (!valid) return;

                      if (requiresDeposit && _screenshotFile != null) {
                        final screenshotUrl = await _uploadScreenshot();
                        if (screenshotUrl != null) {
                          controller.confirmReservation(
                            transfer_url_image: screenshotUrl,
                          );
                          Navigator.pop(context);
                        }
                      } else {
                        controller.confirmReservation();
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
