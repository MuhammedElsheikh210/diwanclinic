import '../../../../../index/index_main.dart';

class OrdersSectionView extends StatelessWidget {
  final HomePatientController controller;

  const OrdersSectionView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.activeOrders;

      return Column(
        children: [
          HeaderSectionWidget(
            title: "طلباتي",
            onMore: () {
              Get.find<MainPageViewModel>().changeIndex(2);
            },
          ),
          SizedBox(height: 15.h),
          if (list.isEmpty)
            NoDataAnimated(
              title: "لا توجد طلبات حالياً",
              subtitle: "لم يتم العثور على أي طلبات",
              lottiePath: Animations.empty,
              height: 220.h,
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(list.length, (i) {
                  final order = list[i];

                  return Padding(
                    padding: EdgeInsets.only(right: 15.w),
                    child: SizedBox(
                      width: 380.w,
                      child: OrderCard(
                        order: order,
                        from_home: true,

                        onConfirmOrder:
                            () => _showConfirmDialog(context, order, controller),

                        onCancelOrder:
                            () => _showCancelDialog(context, order, controller),

                        onOrderDetails:
                            () => Get.to(() => OrderDetailsScreen(order: order)),

                        onFollowTreatment:
                            () => Get.to(() => const TreatmentTrackingListScreen()),

                        onPriceDetails:
                            () => Get.to(
                              () => PriceDetailsScreen(order: order, fromHome: true),
                            ),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      );
    });
  }

  void _showConfirmDialog(
    BuildContext context,
    OrderModel order,
    HomePatientController controller,
  ) {
    ActionDialogHelper.show(
      context: context,
      title: "تأكيد الطلب",
      message: "هل تريد تأكيد هذا الطلب وإرسال إشعار ورسالة واتساب؟",
      confirmText: "تأكيد",
      confirmColor: AppColors.primary,
      onConfirm: () {
        controller.updateOrderStatus(order: order, newStatus: "confirmed");
      },
    );
  }

  void _showCancelDialog(
    BuildContext context,
    OrderModel order,
    HomePatientController controller,
  ) {
    ActionDialogHelper.show(
      context: context,
      title: "إلغاء الطلب",
      message:
          "هل أنت متأكد من إلغاء هذا الطلب؟ لا يمكن التراجع عن هذا الإجراء.",
      confirmText: "إلغاء",
      confirmColor: AppColors.errorForeground,
      onConfirm: () {
        controller.updateOrderStatus(order: order, newStatus: "cancelled");
      },
    );
  }
}
