import 'package:diwanclinic/Presentation/screens/notification/notifiction_controller.dart';

import '../../../../index/index_main.dart';

class NotificationBottomSheet extends StatelessWidget {
  final NotificationController controller = Get.put(NotificationController());

  NotificationBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20.w,
        right: 20.w,
        top: 16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "إرسال إشعار جديد",
            style: context.typography.lgBold,
          ),
          SizedBox(height: 16.h),

          /// 🔹 Title
          AppTextField(
            controller: controller.titleController,
            hintText: "عنوان الإشعار (مثال: الطبيب في الطريق)",
            keyboardType: TextInputType.text,
            validator: InputValidators.combine([notEmptyValidator]),
          ),
          SizedBox(height: 12.h),

          /// 🔹 Body
          AppTextField(
            controller: controller.bodyController,
            hintText: "نص الإشعار (مثال: سيتم تأخير الموعد لمدة 15 دقيقة)",
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            validator: InputValidators.combine([notEmptyValidator]),
          ),
          SizedBox(height: 20.h),

          /// 🔹 Send Button
          SizedBox(
            width: ScreenUtil().screenWidth,
            height: 48.h,
            child: PrimaryTextButton(
              onTap: () {
                final title = controller.titleController.text.trim();
                final body = controller.bodyController.text.trim();

                if (title.isEmpty || body.isEmpty) {
                  Loader.showError("الرجاء إدخال عنوان ونص الإشعار");
                  return;
                }

                controller.addNotification(
                  title: title,
                  body: body,
                  toKey: "all", // 🔹 You can make this dynamic if needed
                );

                Get.back();
              },
              label: AppText(
                text: "إرسال الإشعار",
                textStyle: context.typography.mdBold.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
