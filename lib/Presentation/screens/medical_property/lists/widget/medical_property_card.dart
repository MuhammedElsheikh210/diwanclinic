import '../../../../../index/index_main.dart';

class MedicalPropertyCard extends StatelessWidget {
  final MedicalRecordPropertyModel property;

  final MedicalPropertyViewModel controller;

  const MedicalPropertyCard({
    Key? key,

    required this.property,

    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),

      margin: EdgeInsets.only(bottom: 10.h),

      width: MediaQuery.of(context).size.width,

      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderNeutralPrimary, width: 1),

        borderRadius: BorderRadius.circular(10),
      ),

      child: Row(
        children: [
          /// Property Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  /// Property Name
                  Text(
                    property.label ?? "",

                    style: context.typography.lgBold.copyWith(
                      color: AppColors.background_black,

                      fontSize: 16,
                    ),
                  ),

                  SizedBox(height: 5.h),

                  /// Property Type
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,

                      vertical: 4.h,
                    ),

                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .08),

                      borderRadius: BorderRadius.circular(8.r),
                    ),

                    child: Text(
                      _getTypeName(property.type),

                      style: context.typography.smMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Actions
          Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              /// Edit
              InkWell(
                onTap: () {
                  showCustomBottomSheet(
                    context: context,

                    child: MedicalPropertyCreate(
                      categoryType: controller.categoryType,

                      categoryEntity: controller.categoryEntity,
                    ),
                  );
                },

                child: Svgicon(
                  icon: IconsConstants.edit_btn,

                  height: 30.h,

                  width: 30.w,
                ),
              ),

              const SizedBox(width: 8),

              /// Delete
              InkWell(
                onTap: () => showConfirmBottomSheet(context),

                child: Svgicon(
                  icon: IconsConstants.delete_btn,

                  height: 30.h,

                  width: 30.w,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ Property Type Name
  String _getTypeName(String? type) {
    switch (type) {
      case "number":
        return "رقم";

      case "date":
        return "تاريخ";

      default:
        return "نص";
    }
  }

  /// ✅ Confirm Delete
  void showConfirmBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),

      builder: (context) {
        return ConfirmBottomSheet(
          title: "هل أنت متأكد من حذف الخاصية؟",

          message: "لن تتمكن من استعادة البيانات بعد الحذف.",

          confirmText: "حذف",

          cancelText: "إلغاء",

          onConfirm: () => _deleteProperty(context),
        );
      },
    );
  }

  /// ✅ Delete Property
  void _deleteProperty(BuildContext context) {
    controller.deleteProperty(property);

    Loader.showSuccess("تم حذف الخاصية بنجاح");
  }
}
