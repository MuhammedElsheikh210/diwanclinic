import '../../../../../index/index_main.dart';

enum OrderTabType { active, finished }

class OrdersListBody extends StatelessWidget {
  final OrdersListViewModel vm;
  final OrderTabType type;

  const OrdersListBody({super.key, required this.vm, required this.type});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list =
          type == OrderTabType.active ? vm.activeOrders : vm.finishedOrders;

      if (list.isEmpty) {
        return NoDataAnimated(
          title: "لا توجد طلبات حالياً",
          subtitle: "لم يتم العثور على أي طلبات",
          lottiePath: Animations.empty,
          actionText: "إضافة طلب جديد",
          onAction: () {
            final user = Get.find<UserSession>().user;

            // Build reservation with urls
            final reservation = ReservationModel(
              patientUid: user?.uid,
              patientFcm: user?.fcmToken,
              patientPhone: user?.phone,
              patientName: user?.name,
            );

            Get.to(
              () => OrderMedicineScreen(
                reservation: reservation,
                onConfirmed: (ReservationModel p1) {
                  Get.off(() => const OrderSuccessView());
                },
              ),
              binding: Binding(),
            );
          },
          height: 220.h,
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final order = list[i];

          return OrderCard(
            order: order,
            onConfirmOrder: () => _showConfirmDialog(context, order),
            onCancelOrder: () => _showCancelDialog(context, order),
            onOrderDetails:
                () => Get.to(() => OrderDetailsScreen(order: order)),
            onFollowTreatment:
                () => Get.to(() => const TreatmentTrackingListScreen()),
            onPriceDetails:
                () => Get.to(
                  () => PriceDetailsScreen(order: order, fromHome: false),
                ),
          );
        },
      );
    });
  }

  void _showConfirmDialog(BuildContext context, OrderModel order) {
    ActionDialogHelper.show(
      context: context,
      title: "تأكيد الطلب",
      message: "هل تريد تأكيد هذا الطلب؟",
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
      message: "هل أنت متأكد من الإلغاء؟",
      confirmText: "إلغاء",
      confirmColor: AppColors.errorForeground,
      onConfirm: () {
        vm.updateOrderStatus(order: order, newStatus: "cancelled");
      },
    );
  }
}
