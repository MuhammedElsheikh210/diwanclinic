import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';
import 'payment_selection_sheet.dart';

class PriceDetailsScreen extends StatefulWidget {
  final OrderModel order;
  final bool fromHome;

  const PriceDetailsScreen({
    super.key,
    required this.order,
    required this.fromHome,
  });

  @override
  State<PriceDetailsScreen> createState() => _PriceDetailsScreenState();
}

class _PriceDetailsScreenState extends State<PriceDetailsScreen> {
  late List<MedicineItemModel> medicines;

  @override
  void initState() {
    super.initState();
    medicines = widget.order.medicines ?? [];
  }

  // ------------------------------
  // 🔥 حسابات ديناميكية
  // ------------------------------
  num get subtotal {
    num sum = 0;
    for (var m in medicines) {
      sum += (m.price ?? 0) * (m.quantity ?? 1);
    }
    return sum;
  }

  num get delivery => widget.order.deliveryFees ?? 0;

  num get discount => widget.order.discount ?? 0;

  num get finalTotal => subtotal + delivery - discount;

  num get totalBeforeDiscount => subtotal + delivery;

  @override
  Widget build(BuildContext context) {
    final isPending = widget.order.status == "calculated";
    final completed = widget.order.status == "completed";
    final userType = Get.find<UserSession>().user?.user.userType;

    final isPharmacy = userType == UserType.pharmacy;

    // ✅ القيم المعتمدة فقط (من الداتا)
    final num subtotal = widget.order.totalOrder ?? 0;
    final num discount = widget.order.discount ?? 0;
    final num delivery = widget.order.deliveryFees ?? 0;
    final num finalTotal = widget.order.finalAmount ?? 0;

    final num totalBeforeDiscount = subtotal + delivery;

    final double discountPercent =
        totalBeforeDiscount == 0 ? 0 : (discount / totalBeforeDiscount) * 100;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: AppText(
            text: "تفاصيل السعر",
            textStyle: context.typography.lgBold.copyWith(
              color: AppColors.textDisplay,
            ),
          ),
        ),

        body: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // --------------------------------------------------
            // 💳 Section: Payment Info (إن وجد)
            // --------------------------------------------------
            if (widget.order.paymentMethod != null &&
                widget.order.paymentMethod!.isNotEmpty)
              _section(
                context: context,
                title: "طريقة الدفع",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.order.paymentMethod == 'cash'
                              ? Icons.money_outlined
                              : widget.order.paymentMethod == 'instapay'
                                  ? Icons.bolt_outlined
                                  : Icons.account_balance_wallet_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8.w),
                        AppText(
                          text: widget.order.paymentMethod == 'cash'
                              ? 'كاش'
                              : widget.order.paymentMethod == 'instapay'
                                  ? 'InstaPay'
                                  : 'محفظة إلكترونية',
                          textStyle: context.typography.mdBold.copyWith(
                            color: AppColors.textDisplay,
                          ),
                        ),
                      ],
                    ),
                    if (widget.order.paymentScreenshotUrl != null &&
                        widget.order.paymentScreenshotUrl!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      AppText(
                        text: "إيصال الدفع",
                        textStyle: context.typography.smSemiBold.copyWith(
                          color: AppColors.textSecondaryParagraph,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: () => Get.to(
                          () => _FullScreenImage(
                            url: widget.order.paymentScreenshotUrl!,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.order.paymentScreenshotUrl!,
                            height: 180.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                    ? child
                                    : Container(
                                        height: 180.h,
                                        color: AppColors.background_neutral_25,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // --------------------------------------------------
            // 🟦 Section: Medicines
            // --------------------------------------------------
            _section(
              context: context,
              title: "الأدوية",
              child: Column(
                children:
                    medicines.map((m) {
                      return MedicineItem(
                        medicine: m,
                        isPending: isPending,
                        onChanged: (updated) {
                          setState(() {
                            int index = medicines.indexOf(m);
                            medicines[index] = updated;
                          });
                        },
                      );
                    }).toList(),
              ),
            ),

            // --------------------------------------------------
            // 🟧 Summary Section
            // --------------------------------------------------
            _section(
              context: context,
              title: "الملخص",
              child: Column(
                children: [
                  // SummaryRow(label: "إجمالي الأدوية", value: "$subtotal ج.م"),
                  //
                  // SummaryRow(label: "التوصيل", value: "$delivery ج.م"),
                  SummaryRow(label: "الإجمالي ", value: "${subtotal} ج.م"),

                  SummaryRow(label: "التوصيل ", value: "${delivery} ج.م"),

                  if (discount > 0)
                    SummaryRow(
                      label: "الخصم",
                      value: "-$discount ج.م (${discountPercent.toStringAsFixed(0)}%)",
                      valueColor: AppColors.errorForeground,
                    ),

                  const Divider(color: AppColors.grayLight),

                  SummaryRow(
                    label: "الإجمالي النهائي",
                    value: "$finalTotal ج.م",
                    isBold: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            if (isPending && !isPharmacy)
              PrimaryTextButton(
                appButtonSize: AppButtonSize.xxLarge,
                onTap: () => _showPaymentSheet(context),
                label: AppText(
                  text: "تأكيد الطلب",
                  textStyle: context.typography.mdBold.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),

            const SizedBox(height: 15),
            completed
                ? const SizedBox()
                : PrimaryTextButton(
                  appButtonSize: AppButtonSize.xxLarge,
                  customBackgroundColor: AppColors.errorForeground,
                  onTap: () => _showCancelOrderDialog(context),
                  label: AppText(
                    text: "إلغاء الطلب",
                    textStyle: context.typography.mdBold.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _showCancelOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: AppText(
              text: "إلغاء الطلب",
              textStyle: context.typography.lgBold.copyWith(
                color: AppColors.textDisplay,
              ),
            ),
            content: AppText(
              text:
                  "هل أنت متأكد من إلغاء هذا الطلب؟\nلا يمكن التراجع بعد الإلغاء.",
              textStyle: context.typography.mdMedium.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: AppText(
                  text: "رجوع",
                  textStyle: context.typography.mdMedium.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Get.back();
                  await _cancelOrder();
                },
                child: AppText(
                  text: "إلغاء الطلب",
                  textStyle: context.typography.mdBold.copyWith(
                    color: AppColors.errorForeground,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _cancelOrder() async {
    Loader.show();

    await OrderStatusService.updateOrderStatus(
      order: widget.order,
      newStatus: "cancelled",
      onSave: (updatedOrder) async {
        await OrderService().updateOrderData(
          order: updatedOrder,
          sideEffects: const OrderSideEffects(
            sendWhatsApp: true,
            sendNotification: true,
          ),
          voidCallBack: (_) async {
            Loader.dismiss();

            if (widget.fromHome == true) {
              Get.offAll(
                () => const MainPage(initialIndex: 0),
                binding: Binding(),
              );
            } else {
              Get.back(); // تفاصيل السعر
              Get.back(); // تفاصيل الطلب
            }
          },
        );
      },
    );
  }

  // ---------------------------------------------------------
  // PAYMENT SHEET → then confirm
  // ---------------------------------------------------------
  Future<void> _showPaymentSheet(BuildContext context) async {
    final result = await showModalBottomSheet<({String method, String? screenshotUrl})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentSelectionSheet(
        finalAmount: widget.order.finalAmount ?? 0,
        walletNumber: widget.order.pharmacyWalletNumber,
        instapayNumber: widget.order.pharmacyInstapayNumber,
        instapayLink: widget.order.pharmacyInstapayLink,
      ),
    );

    if (result == null) return;

    Loader.show();

    final updatedOrderForConfirm = widget.order.copyWith(
      medicines: medicines,
      totalOrder: subtotal,
      deliveryFees: delivery,
      discount: discount,
      finalAmount: finalTotal,
      paymentMethod: result.method,
      paymentScreenshotUrl: result.screenshotUrl,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await OrderStatusService.updateOrderStatus(
      order: updatedOrderForConfirm,
      newStatus: "confirmed",
      onSave: (updatedOrder) async {
        await OrderService().updateOrderData(
          order: updatedOrder,
          sideEffects: const OrderSideEffects(
            sendWhatsApp: true,
            sendNotification: true,
          ),
          voidCallBack: (_) async {
            // 🔔 in-app notification → كتابة مباشرة على path الصيدلاني
            final pharmacyUid = updatedOrder.pharmacyKey;
            if (pharmacyUid != null && pharmacyUid.isNotEmpty) {
              final notifKey = const Uuid().v4();
              await FirebaseDatabase.instance
                  .ref("notifications/$pharmacyUid/$notifKey")
                  .set({
                'key': notifKey,
                'from_key': Get.find<UserSession>().user?.uid,
                'to_key': pharmacyUid,
                'title': '✅ تم تأكيد الطلب',
                'body':
                    'قام ${updatedOrder.patientName ?? "المريض"} بتأكيد الطلب وجاهز للتجهيز',
                'notification_type': 'order_confirmed',
                'create_at': DateTime.now().millisecondsSinceEpoch,
                'is_read': false,
                'extra_data': {'order_key': updatedOrder.key},
              });
            }

            Loader.dismiss();
            if (widget.fromHome == true) {
              Get.offAll(
                () => const MainPage(initialIndex: 0),
                binding: Binding(),
              );
            } else {
              OrdersListViewModel controller =
                  initController(() => OrdersListViewModel());
              controller.update();
              Get.back();
              Get.back();
            }
          },
        );
      },
    );
  }

  // ------------------------------
  // 🔥 UI Section Component
  // ------------------------------
  Widget _section({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: title,
              textStyle: context.typography.mdBold.copyWith(
                color: AppColors.textDisplay,
              ),
            ),
            SizedBox(height: 14.h),
            child,
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 🔥 Medicine Item Widget
// ---------------------------------------------------------
class MedicineItem extends StatelessWidget {
  final MedicineItemModel medicine;
  final bool isPending;
  final Function(MedicineItemModel) onChanged;

  const MedicineItem({
    super.key,
    required this.medicine,
    required this.isPending,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final unit = medicine.price ?? 0;
    final qty = medicine.quantity ?? 1;
    final total = unit * qty;

    return Card(
      elevation: 0,
      color: AppColors.background_neutral_25,
      margin: EdgeInsets.only(bottom: 14.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            // LEFT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: medicine.name ?? "",
                    textStyle: context.typography.mdBold.copyWith(
                      color: AppColors.textDisplay,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  AppText(
                    text: "سعر الوحدة: $unit ج.م",
                    textStyle: context.typography.smRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  AppText(
                    text: "الإجمالي: $total ج.م",
                    textStyle: context.typography.mdBold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // RIGHT — counter
            AppText(text: qty.toString(), textStyle: context.typography.mdBold),
          ],
        ),
      ),
    );
  }

  Widget _counterBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 34.w,
        height: 34.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderNeutralPrimary),
          color: AppColors.background_neutral_25,
        ),
        child: Icon(icon, size: 20.w),
      ),
    );
  }
}

// ---------------------------------------------------------
// FULL SCREEN IMAGE VIEWER
// ---------------------------------------------------------
class _FullScreenImage extends StatelessWidget {
  final String url;
  const _FullScreenImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// SUMMARY ROW UI
// ---------------------------------------------------------
class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: label,
            textStyle: typography.smRegular.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
          AppText(
            text: value,
            textStyle: (isBold ? typography.mdBold : typography.smMedium)
                .copyWith(color: valueColor ?? AppColors.textDisplay),
          ),
        ],
      ),
    );
  }
}
