import '../../../../index/index_main.dart';

void showDeleteBottomSheet(
  BuildContext context, {
  required VoidCallback onDelete,
}) {
  showCustomBottomSheet(
    context: context,
    child: SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title Row with X Button
          Row(
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: const Svgicon(icon: IconsConstants.cancel),
              ),
              Expanded(
                child: Text(
                  "هل تريد حذف هذا العنصر؟",
                  textAlign: TextAlign.center,
                  style: context.typography.mdMedium.copyWith(
                    color: AppColors.background_black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Description
          Text(
            "لا يمكنك استعادة البيانات بعد الحذف",
            style: context.typography.smMedium.copyWith(
              color: AppColors.grayMedium,
            ),
          ),

          const SizedBox(height: 30),

          // Delete Button
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: PrimaryTextButton(
              appButtonSize: AppButtonSize.xlarge,
              customBackgroundColor: AppColors.errorForeground,
              onTap: () {
                onDelete(); // Execute delete action
              },
              label: AppText(
                textStyle: context.typography.mdBold.copyWith(
                  color: AppColors.white,
                ),
                text: "حذف",
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
