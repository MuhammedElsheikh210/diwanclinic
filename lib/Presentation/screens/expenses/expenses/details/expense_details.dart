import '../../../../../index/index_main.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final TransactionsEntity expense;

  const ExpenseDetailScreen({Key? key, required this.expense})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Header Section
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary, // Red background
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25.r),
                  bottomRight: Radius.circular(25.r),
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 40.h,
              ),
              child: Column(
                children: [
                  // Top bar with back button & delete icon
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 10.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Get.back(),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "تفاصيل المعاملة",
                              style: context.typography.lgBold.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount, Title & Date
                  Text(
                    "${expense.totalAmount ?? "0"} ج.م",
                    style: context.typography.xlBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0.h),
                    child: Text(
                      expense.bileTitle ?? "مصروفات",
                      style: context.typography.mdBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(expense.createAt),
                    style: context.typography.smRegular.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Type, Category, Wallet Tabs
            Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 5),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoTab("النوع", "مصروف", context),
                    _infoTab("الفئة", expense.bileTitle ?? "غير محدد", context),
                    _infoTab(
                      "المحفظة",
                      expense.walletName ?? "غير محدد",
                      context,
                    ),
                  ],
                ),
              ),
            ),

            // Attachment Section
            if (expense.status != null)
              Expanded(child: _receiptImage(expense.status!)),

            // Edit Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Handle edit action
                  
                },
                child: Text(
                  "تعديل",
                  style: context.typography.mdBold.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Format timestamp to readable date
  String _formatDate(int? timestamp) {
    if (timestamp == null) return "غير متاح";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}  ${date.hour}:${date.minute}";
  }

  // Info Tab Widget
  Widget _infoTab(String title, String value, BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: context.typography.smRegular.copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: context.typography.mdBold.copyWith(color: Colors.black),
        ),
      ],
    );
  }

  // Receipt Image Widget
  Widget _receiptImage(String imageUrl) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          "https://gratisography.com/wp-content/uploads/2024/11/gratisography-augmented-reality-800x525.jpg",
          width: double.infinity,
          height: 250.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
