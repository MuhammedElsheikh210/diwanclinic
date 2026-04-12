import '../../../../../index/index_main.dart';

class OrdersSectionView extends StatelessWidget {
  final HomePatientController controller;

  const OrdersSectionView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final list = controller.activeOrders;

    if (list.isEmpty) {
      return NoDataAnimated(
        title: "لا توجد طلبات حالياً",
        subtitle: "لم يتم العثور على أي طلبات",
        lottiePath: Animations.empty,
        actionText: "إضافة طلب جديد",
        onAction: () {
          final currentUser = Get.find<UserSession>().user;

          final reservation = ReservationModel(
            patientKey: currentUser?.user.uid,
            // أو key حسب system عندك
            patientUid: currentUser?.user.uid,
            fcmToken_patient: currentUser?.user.fcmToken,
            patientPhone: currentUser?.user.phone,
            patientName: currentUser?.user.name,
          );

          Get.to(
            () => OrderMedicineScreen(
              reservation: reservation,
              onConfirmed: (ReservationModel p1) {
                // controller.updateReservation(p1);
                Get.offAll(
                  () => const MainPage(initialIndex: 2),
                  binding: Binding(),
                );
              },
            ),
            binding: Binding(),
          );
        },
        height: 220.h,
      );
    }

    return Column(
      children: [
        HeaderSectionWidget(
          title: "طلباتي",
          onMore: () => Get.offAll(() => const MainPage(initialIndex: 2)),
        ),
        SizedBox(height: 15.h),
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
                          () =>
                              PriceDetailsScreen(order: order, fromHome: true),
                        ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
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
