import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Title
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: const Icon(Icons.cancel_outlined),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "تأكيد الحجز",
                          textAlign: TextAlign.center,
                          style: typography.xlBold.copyWith(
                            color: AppColors.textDisplay,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // // 🔹 رقم الكشف (Order number)
                // if (controller.nextOrder != null)
                //   Container(
                //     width: double.infinity,
                //     padding: EdgeInsets.all(12.w),
                //     decoration: BoxDecoration(
                //       color: AppColors.primary10,
                //       borderRadius: BorderRadius.circular(12.r),
                //       border: Border.all(color: AppColors.primary40),
                //     ),
                //     child: Text(
                //       "رقم الكشف: ${controller.nextOrder}",
                //       style: typography.lgBold.copyWith(
                //         color: AppColors.primary,
                //       ),
                //     ),
                //   ),

                /// 🔹 اختيار الشيفت
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("اختر الفترة", style: typography.mdMedium),
                    const SizedBox(height: 8),

                    controller.listShifts == null
                        ? const SizedBox()
                        : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              controller.listShifts!.map((shift) {
                                final isSelected =
                                    controller.selectedShift?.key == shift?.key;

                                return GestureDetector(
                                  onTap: () async {
                                    controller.selectedShift = shift;

                                    // 🔥 أهم حاجة
                                    await controller
                                        .loadLegacyQueueForSelectedDate();
                                    await controller
                                        .loadOpenCloseStatusForSelectedDate();

                                    controller.update();
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? AppColors.primary.withValues(
                                                alpha: 0.1,
                                              )
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? AppColors.primary
                                                : Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                      boxShadow:
                                          isSelected
                                              ? [
                                                BoxShadow(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.15),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]
                                              : [],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 18,
                                          color:
                                              isSelected
                                                  ? AppColors.primary
                                                  : Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          shift?.name ?? "",
                                          style: typography.mdMedium.copyWith(
                                            color:
                                                isSelected
                                                    ? AppColors.primary
                                                    : Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                  ],
                ),

                /// 🔹 نوع الحجز
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 17.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("نوع الحجز", style: typography.mdMedium),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            controller.reservationTypes.map((type) {
                              final isSelected =
                                  controller.selectedReservationType == type;

                              return GestureDetector(
                                onTap: () {
                                  controller.selectedReservationType = type;
                                  controller.update();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? AppColors.primary.withOpacity(0.1)
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                    boxShadow:
                                        isSelected
                                            ? [
                                              BoxShadow(
                                                color: AppColors.primary
                                                    .withOpacity(0.15),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ]
                                            : [],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 18,
                                        color:
                                            isSelected
                                                ? AppColors.primary
                                                : Colors.transparent,
                                      ),
                                      if (isSelected) const SizedBox(width: 6),
                                      Text(
                                        type,
                                        style: typography.mdMedium.copyWith(
                                          color:
                                              isSelected
                                                  ? AppColors.primary
                                                  : Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),

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
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("تاريخ الكشف", style: typography.mdMedium),
                    const SizedBox(height: 8),
                    CalenderWidget(
                      onDateSelected: (timeStamp, date) {
                        final pickedDate = DateTime.fromMillisecondsSinceEpoch(
                          timeStamp.millisecondsSinceEpoch,
                        );
                        controller.onSelectDate(pickedDate);
                      },
                      initialTimestamp:
                          controller.selectedDate != null
                              ? controller.selectedDate!.millisecondsSinceEpoch
                              : DateTime.now().millisecondsSinceEpoch,
                      hintText: "اختر تاريخ الحجز",
                    ),
                  ],
                ),

                SizedBox(height: 15.h),

                if (!controller.isSelectedDayClosed) ...[
                  // ⚡ حالة الكشف المستعجل
                  if (controller.selectedReservationType == "كشف مستعجل")
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      margin: EdgeInsets.only(top: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary10,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.primary40),
                      ),
                      child: Text(
                        "⚡ يتم استقبال الحالات المستعجلة فور الوصول، يُرجى التنسيق مع المساعدة لضمان سرعة الخدمة",
                        style: typography.mdMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  // 🧠 باقي الحالات (عادي / إعادة)
                  else ...[
                    if (controller.isLoadingOrderInfo)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: const CircularProgressIndicator(),
                      )
                    else if (controller.beforeYouCount != null)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 12.h),
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.08),
                              AppColors.primary.withOpacity(0.03),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // 🔵 Icon Circle
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.groups_rounded,
                                color: AppColors.primary,
                                size: 22.sp,
                              ),
                            ),

                            SizedBox(width: 12.w),

                            // 📊 Texts
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 👥 قبلّك
                                  Text(
                                    "هيكون قبلك ${controller.beforeYouCount} حالة",
                                    style: typography.mdMedium.copyWith(
                                      color: AppColors.textDisplay,
                                    ),
                                  ),

                                  SizedBox(height: 4.h),

                                  // 📌 دورك
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.confirmation_number_outlined,
                                        size: 16.sp,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        "دورك رقم ${controller.expectedOrder}",
                                        style: typography.lgBold.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],

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
                      if (controller.isSelectedDayClosed) {
                        Loader.showError("🚫 هذا اليوم مغلق للحجوزات");
                        return;
                      }
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

                if (controller.isSelectedDayClosed)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 15,
                      left: 10,
                      right: 10,
                    ),
                    child: Text(
                      "🚫 هذا اليوم مُغلق ولا يمكن الحجز فيه",
                      style: context.typography.smMedium.copyWith(
                        color: AppColors.errorForeground,
                      ),
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
