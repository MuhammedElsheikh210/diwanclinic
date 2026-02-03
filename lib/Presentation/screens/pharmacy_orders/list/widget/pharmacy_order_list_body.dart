import 'package:diwanclinic/Presentation/screens/pharmacy_orders/PricingSearchView/PricingSearchView.dart';

import '../../../../../index/index_main.dart';

class PharmacyOrdersListBody extends StatelessWidget {
  final PharmacyOrdersListViewModel vm;

  const PharmacyOrdersListBody({super.key, required this.vm});

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

          return PharmacyOrderCard(
            order: order,

            onConfirmOrder: () => _showConfirmDialog(context, order),

            onCancel: () => _showCancelDialog(context, order),
            onApprovedOrder: () => _showApprovedDialog(context, order),

            onOrderDetails: () =>
                Get.to(() => OrderDetailsScreen(order: order)),
            onFollowTreatment: () =>
                Get.to(() => const TreatmentTrackingListScreen()),
            onPriceDetails: () =>
                Get.to(() => PricingSearchView(orderModel: order)),
            onShowPriceDetails: () =>
                Get.to(() => PriceDetailsScreen(order: order, fromHome: false)),
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
        vm.updateOrderStatus(order: order, newStatus: "completed");
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

  void _showApprovedDialog(BuildContext context, OrderModel order) {
    ActionDialogHelper.show(
      context: context,
      title: "بدء تسعير الطلب",
      message:
          "هل تريد بدء تسعير هذا الطلب الآن؟ سيتم إبلاغ المريض بأن الطلب قيد التسعير.",
      confirmText: "بدء التسعير",
      confirmColor: AppColors.tag_icon_warning,
      onConfirm: () {
        vm.updateOrderStatus(order: order, newStatus: "approved");
      },
    );
  }
}
