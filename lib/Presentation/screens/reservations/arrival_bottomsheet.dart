import '../../../../index/index_main.dart';

class DoctorArrivalBottomSheet extends StatefulWidget {
  final Future<void> Function()? onNotifyArrival;

  // ✅ Updated: Now this callback accepts title & body from the form
  final Future<void> Function(String title, String body)? onNotifyDelay;

  const DoctorArrivalBottomSheet({
    super.key,
    this.onNotifyArrival,
    this.onNotifyDelay,
  });

  @override
  State<DoctorArrivalBottomSheet> createState() =>
      _DoctorArrivalBottomSheetState();
}

class _DoctorArrivalBottomSheetState extends State<DoctorArrivalBottomSheet> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  bool willBeLate = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              Center(
                child: Text(
                  "تحديث حالة الطبيب",
                  style: context.typography.lgBold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // 🔹 Buttons
              Row(
                children: [
                  Expanded(
                    child: PrimaryTextButton(
                      appButtonSize: AppButtonSize.xlarge,
                      onTap: () async {
                        Get.back();
                        Loader.showSuccess("تم تسجيل وصولك بنجاح 👨‍⚕️");
                        if (widget.onNotifyArrival != null) {
                          await widget.onNotifyArrival!();
                        }
                      },
                      label: AppText(
                        text: "✅ وصلت الآن",
                        textStyle: context.typography.mdBold.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(width: 10.w),
                  // Expanded(
                  //   child: OutlinedButton(
                  //     onPressed: () => setState(() => willBeLate = !willBeLate),
                  //     style: OutlinedButton.styleFrom(
                  //       side: BorderSide(
                  //         color: willBeLate
                  //             ? AppColors.primary
                  //             : AppColors.borderNeutralPrimary,
                  //       ),
                  //     ),
                  //     child: Text(
                  //       "⏰ سأتأخر",
                  //       style: context.typography.mdMedium.copyWith(
                  //         color: willBeLate
                  //             ? AppColors.primary
                  //             : AppColors.grayMedium,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              SizedBox(height: 20.h),

              if (willBeLate) ...[
                CustomInputField(
                  label: "عنوان الإشعار",
                  hintText: "اكتب عنوان التنبيه (مثال: تأجيل المواعيد)",
                  controller: titleController,
                  focusNode: FocusNode(),
                  keyboardType: TextInputType.text,
                  validator: InputValidators.combine([notEmptyValidator]),
                ),
                SizedBox(height: 10.h),
                CustomInputField(
                  label: "محتوى الإشعار",
                  focusNode: FocusNode(),
                  keyboardType: TextInputType.text,
                  hintText: "اكتب سبب التأخير أو المدة المتوقعة...",
                  controller: bodyController,
                  validator: InputValidators.combine([notEmptyValidator]),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: ScreenUtil().screenWidth,
                  height: 50.h,
                  child: PrimaryTextButton(
                    onTap: () async => _sendLateNotification(),
                    label: AppText(
                      text: isLoading ? "جاري الإرسال..." : "إرسال الإشعار 📢",
                      textStyle: context.typography.mdBold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Send custom delay notification
  Future<void> _sendLateNotification() async {
    if (titleController.text.isEmpty || bodyController.text.isEmpty) {
      Loader.showError("يرجى كتابة عنوان ومحتوى الإشعار");
      return;
    }

    setState(() => isLoading = true);
    try {
      if (widget.onNotifyDelay != null) {
        await widget.onNotifyDelay!(
          titleController.text.trim(),
          bodyController.text.trim(),
        );
      }
      Loader.showSuccess("تم إرسال إشعار التأخير إلى المرضى ✅");
      Get.back();
    } catch (e) {
      Loader.showError("حدث خطأ أثناء الإرسال: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }
}
