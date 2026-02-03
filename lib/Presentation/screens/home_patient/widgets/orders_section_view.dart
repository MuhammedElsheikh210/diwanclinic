import 'package:diwanclinic/Presentation/screens/patient_orders/details/order_details_view.dart';
import 'package:diwanclinic/Presentation/screens/patient_orders/list/widget/action_dialog_helper.dart';
import 'package:diwanclinic/Presentation/screens/patient_orders/list/widget/order_card.dart';
import 'package:diwanclinic/Presentation/screens/patient_orders/price_details_view/view.dart';
import 'package:diwanclinic/Presentation/screens/patient_orders/treatement_track/view.dart';
import '../../../../../index/index_main.dart';

class OrdersSectionView extends StatelessWidget {
  final HomePatientController controller;

  const OrdersSectionView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final list = controller.orders;

    if (list.isEmpty) {
      return NoDataAnimated(
        title: "لا توجد طلبات حالياً",
        subtitle: "لم تقم بأي طلب حتى الآن",
        lottiePath: Animations.empty,
        height: 200.h,
      );
    }

    return Column(
      children: [
        HeaderSectionWidget(
          title: "طلباتي",
          onMore: () => Get.offAll(() => const MainPage(initialIndex:2)),
        ),
        SizedBox(height: 15.h,),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(list.length, (i) {
              final order = list[i];

              return Padding(
                padding: EdgeInsets.only(right: 14.w),
                child: SizedBox(
                  width: 400.w,
                  child: OrderCard(
                    order: order,

                    onConfirmOrder: () =>
                        _showConfirmDialog(context, order, controller),

                    onCancelOrder: () =>
                        _showCancelDialog(context, order, controller),

                    onOrderDetails: () =>
                        Get.to(() => OrderDetailsScreen(order: order)),

                    onFollowTreatment: () =>
                        Get.to(() => const TreatmentTrackingListScreen()),

                    onPriceDetails: () => Get.to(
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
