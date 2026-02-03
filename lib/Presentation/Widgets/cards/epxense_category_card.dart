import '../../../index/index_main.dart';
import '../../screens/expenses/category_expense/expense_category_create/category_create.dart';
import '../../screens/expenses/category_expense/lists/category_view_model.dart';

class ExpenseCategoryCard extends StatelessWidget {
  final CategoryEntity categoryEntity;
  final CategoryExpenseViewModel controller;

  const ExpenseCategoryCard({
    Key? key,
    required this.categoryEntity,
    required this.controller,
  }) : super(key: key);

  /// 🔄 Convert categoryType key to readable Arabic text
  String getCategoryTypeLabel(String? type) {
    switch (type) {
      case "fixed":
        return "ثابت";
      case "monthly":
        return "شهري";
      default:
        return "غير معروف";
    }
  }

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
          /// ✅ Title + Subtitle
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryEntity.name ?? "",
                    style: context.typography.lgBold.copyWith(
                      color: AppColors.background_black,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    getCategoryTypeLabel(categoryEntity.categoryType),
                    style: context.typography.mdRegular.copyWith(
                      color: AppColors.background_black,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// ✅ Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  showCustomBottomSheet(
                    context: context,
                    child: CreateExpenseCategoryView(
                      categoryEntity: categoryEntity,
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

  void showConfirmBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return ConfirmBottomSheet(
          title: "هل أنت متأكد من حذف البند؟",
          message: "لن تتمكن من استعادة البيانات بعد الحذف.",
          confirmText: "حذف",
          cancelText: "إلغاء",
          onConfirm: () => _deleteCategory(context),
        );
      },
    );
  }

  void _deleteCategory(BuildContext context) {
    controller.deleteCategory(categoryEntity);
    Loader.showSuccess("تم حذف البند بنجاح");
  }
}
