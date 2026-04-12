import '../../../../index/index_main.dart';

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
                  SummaryRow(
                    label: "الإجمالي ",
                    value: "${delivery + subtotal} ج.م",
                  ),

                  SummaryRow(
                    label: "الخصم",
                    value:
                        "-$discount ج.م (${discountPercent.toStringAsFixed(0)}%)",
                    valueColor: AppColors.errorForeground,
                  ),

                  SizedBox(height: 6.h),

                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.local_offer_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: AppText(
                            text:
                                "عند طلب العلاج مباشرة بدون حجز كشف تحصل على خصم 10٪ على إجمالي الأدوية.",
                            textStyle: context.typography.xsRegular.copyWith(
                              color: AppColors.primary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                onTap: () => _showConfirmPricingDialog(context),
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
  // CONFIRM PRICING DIALOG
  // ---------------------------------------------------------
  void _showConfirmPricingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: AppText(
              text: "تأكيد سعر الطلب",
              textStyle: context.typography.lgBold.copyWith(
                color: AppColors.textDisplay,
              ),
            ),
            content: AppText(
              text:
                  "هل تريد تأكيد التسعير النهائي لهذا الطلب؟\nبعد التأكيد سيتم إرسال السعر للمريض.",
              textStyle: context.typography.mdMedium.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: AppText(
                  text: "إلغاء",
                  textStyle: context.typography.mdMedium.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Loader.show();

                  // 🔥 تحديث الطلب من مكان واحد فقط
                  await OrderStatusService.updateOrderStatus(
                    order: widget.order.copyWith(
                      medicines: medicines,
                      totalOrder: subtotal,
                      deliveryFees: delivery,
                      discount: discount,
                      finalAmount: finalTotal,
                      updatedAt: DateTime.now().millisecondsSinceEpoch,
                    ),
                    newStatus: "confirmed",
                    onSave: (updatedOrder) async {
                      await OrderService().updateOrderData(
                        order: updatedOrder,
                        sideEffects: const OrderSideEffects(
                          sendWhatsApp: true,
                          sendNotification: true,
                        ),
                        voidCallBack: (_) async {
                          if (widget.fromHome == true) {
                            Get.offAll(
                              () => const MainPage(initialIndex: 0),
                              binding: Binding(),
                            );
                          } else {
                            OrdersListViewModel controller = initController(
                              () => OrdersListViewModel(),
                            );
                            controller.fetchOrders();
                            controller.update();
                            Get.back();
                            Get.back();
                          }

                          Loader.dismiss();
                          // إغلاق شاشة التفاصيل
                        },
                      );
                    },
                  );
                },
                child: AppText(
                  text: "تأكيد",
                  textStyle: context.typography.mdBold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
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
                  // AppText(
                  //   text: "سعر الوحدة: $unit ج.م",
                  //   textStyle: context.typography.smRegular.copyWith(
                  //     color: AppColors.textSecondaryParagraph,
                  //   ),
                  // ),
                  // SizedBox(height: 8.h),
                  // AppText(
                  //   text: "السعر الكلي: $total ج.م",
                  //   textStyle: context.typography.mdBold.copyWith(
                  //     color: AppColors.primary,
                  //   ),
                  // ),
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
