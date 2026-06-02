import 'package:diwanclinic/Presentation/screens/pharmacy_chat/pharmacy_chat_detail_view.dart';
import 'package:diwanclinic/Presentation/screens/pharmacy_orders/PricingSearchView/PricingSearchView.dart';
import 'package:diwanclinic/Presentation/screens/pharmacy_orders/list/bottom_sheets/cancel_with_reason_dialog.dart';

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

            onOrderDetails:
                () => Get.to(() => OrderDetailsScreen(order: order)),
            onFollowTreatment:
                () => Get.to(() => const TreatmentTrackingListScreen()),
            onPriceDetails:
                () => Get.to(() => PricingSearchView(orderModel: order)),
            onShowPriceDetails:
                () => Get.to(
                  () => PriceDetailsScreen(order: order, fromHome: false),
                ),
            onChat: (order.patientuid != null && order.patientuid!.isNotEmpty)
                ? () {
                    final session = Get.find<UserSession>();
                    final pharmacy = session.user?.asPharmacy;
                    final pharmacyId =
                        pharmacy?.pharmacyId ?? pharmacy?.uid ?? session.user?.uid ?? "";
                    final pharmacyName = session.user?.name ?? "الصيدلية";
                    Get.to(
                      () => PharmacyChatDetailView(
                        pharmacyId: pharmacyId,
                        pharmacyName: pharmacyName,
                        patientId: order.patientuid!,
                        patientName: order.patientName ?? "مريض",
                        isPharmacySide: true,
                        receiverFcmToken: order.fcmToken,
                      ),
                      binding: Binding(),
                    );
                  }
                : null,
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
      onConfirm: () async {
        vm.updateOrderStatus(order: order, newStatus: "completed");
        // 🧹 Clear WhatsApp Session
        if (order.createdBy == "whatsapp") {
          await WhatsAppSessionService.markConfirmed(order.whatsApp ?? "");
        }
      },
    );
  }

  void _showCancelDialog(BuildContext context, OrderModel order) {
    CancelWithReasonDialog.show(
      context: context,
      title: "إلغاء الحجز",
      confirmText: "تأكيد الإلغاء",
      reasons: [
        "الدواء غير متوفر في المخزن",
        "الخدمة متاحة في طنطا فقط",
        "خطأ في بيانات الطلب",
        "سبب آخر",
      ],

      onConfirm: (reason) async {
        final updatedOrder = order.copyWith(cancel_reason: reason);

        await vm.updateOrderStatus(order: updatedOrder, newStatus: "cancelled");

        // 🧹 Clear WhatsApp Session
        if (order.createdBy == "whatsapp") {
          await WhatsAppSessionService.markCancelled(order.whatsApp ?? "");
        }
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
