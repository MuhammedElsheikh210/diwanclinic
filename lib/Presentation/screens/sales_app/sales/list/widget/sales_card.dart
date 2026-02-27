

import '../../../../../../index/index_main.dart';

class SalesCard extends StatelessWidget {
  final LocalUser sales;
  final SalesViewModel controller;

  const SalesCard({Key? key, required this.sales, required this.controller})
      : super(key: key);

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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                sales.name ?? "",
                style: context.typography.lgBold.copyWith(
                  color: AppColors.background_black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit Button
              InkWell(
                onTap: () {
                  Get.delete<CreateSalesViewModel>();
                  showCustomBottomSheet(
                    context: context,
                    child: CreateSalesView(sales: sales),
                  );
                },
                child: Svgicon(
                  icon: IconsConstants.edit_btn,
                  height: 30.h,
                  width: 30.w,
                ),
              ),
              const SizedBox(width: 8),

              // Delete Button
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
          title: "هل أنت متأكد من حذف مندوب المبيعات؟",
          message: "لن تتمكن من استعادة البيانات بعد الحذف.",
          confirmText: "حذف",
          cancelText: "إلغاء",
          onConfirm: () => _deleteSales(),
        );
      },
    );
  }

  void _deleteSales() {
    controller.deleteSales(sales);
    Loader.showSuccess("تم حذف مندوب المبيعات بنجاح");
  }
}
