import '../../../../../index/index_main.dart';

class OrdersListBody extends StatelessWidget {
  final OrdersListViewModel vm;

  const OrdersListBody({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (vm.orders.isEmpty) {
        return NoDataAnimated(
          title: "لا توجد طلبات حالياً",
          subtitle: "لم يتم العثور على أي طلبات",
          lottiePath: Animations.empty,
          height: 220.h,
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: vm.orders.length,
        itemBuilder: (_, i) {
          final order = vm.orders[i];

          return OrderCard(
            order: order,

            onConfirmOrder: () => _showConfirmDialog(context, order),

            onCancelOrder: () => _showCancelDialog(context, order),

            onOrderDetails: () =>
                Get.to(() => OrderDetailsScreen(order: order)),
            onFollowTreatment: () =>
                Get.to(() => const TreatmentTrackingListScreen()),
            onPriceDetails: () =>
                Get.to(() => PriceDetailsScreen(order: order,fromHome: false,)),
          );
        },
      );
    });
  }

  void _showConfirmDialog(BuildContext context, OrderModel order) {
    ActionDialogHelper.show(
      context: context,
      title: "تأكيد الطلب",
      message: "هل تريد تأكيد هذا الطلب وإرسال إشعار ورسالة واتساب؟",
      confirmText: "تأكيد",
      confirmColor: AppColors.primary,
      onConfirm: () {
        vm.updateOrderStatus(order: order, newStatus: "confirmed");
      },
    );
  }

  void _showCancelDialog(BuildContext context, OrderModel order) {
    ActionDialogHelper.show(
      context: context,
      title: "إلغاء الطلب",
      message:
          "هل أنت متأكد من إلغاء هذا الطلب؟ لا يمكن التراجع عن هذا الإجراء.",
      confirmText: "إلغاء",
      confirmColor: AppColors.errorForeground,
      onConfirm: () {
        vm.updateOrderStatus(order: order, newStatus: "cancelled");
      },
    );
  }
}
