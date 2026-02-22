import '../../../../../index/index_main.dart';

class PricingSummary extends StatelessWidget {
  final PricingSearchController controller;
  final OrderModel orderModel;

  const PricingSummary({
    super.key,
    required this.controller,
    required this.orderModel,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.typography;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        // ✅ الحل هنا
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "الملخص",
              style: t.mdBold.copyWith(color: AppColors.textDisplay),
            ),
            const SizedBox(height: 12),

            _row(context, label: "قبل الخصم", value: controller.subtotalInt),
            const SizedBox(height: 6),
            _row(
              context,
              label: "الخصم",
              value: -controller.discountValueInt,
              negative: true,
            ),

            const SizedBox(height: 12),

            _sectionTitle(context, "نسبة الخصم"),
            const SizedBox(height: 6),
            _options<double>(
              context,
              values: const [0.05, 0.10],
              selected: controller.discountPercent,
              onSelect: controller.setDiscount,
              formatter: (v) => "${(v * 100).toInt()}%",
            ),

            const SizedBox(height: 12),

            _sectionTitle(context, "التوصيل"),
            const SizedBox(height: 6),
            _options<double>(
              context,
              values: const [15, 20, 25],
              selected: controller.deliveryFee,
              onSelect: controller.setDelivery,
              formatter: (v) => "${v.toStringAsFixed(0)} ج",
            ),

            const SizedBox(height: 16),
            const Divider(),

            _row(
              context,
              label: "الإجمالي النهائي",
              value: controller.totalInt,
              bold: true,
              highlight: true,
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: PrimaryTextButton(
                appButtonSize: AppButtonSize.xxLarge,
                label: AppText(
                  text: "تأكيد التسعير",
                  textStyle: context.typography.mdBold,
                ),
                onTap: () {
                  controller.updateOrderStatus(order: orderModel);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // Helpers
  // --------------------------------------------------

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: context.typography.smMedium.copyWith(
        color: AppColors.textSecondaryParagraph,
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required String label,
    required int value,
    bool bold = false,
    bool negative = false,
    bool highlight = false,
  }) {
    final t = context.typography;

    Color valueColor = AppColors.textDisplay;
    if (negative) valueColor = AppColors.errorForeground;
    if (highlight) valueColor = AppColors.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: t.smRegular.copyWith(color: AppColors.textSecondaryParagraph),
        ),
        Text(
          "${value.toStringAsFixed(1)} ج",
          style: (bold ? t.lgBold : t.mdMedium).copyWith(color: valueColor),
        ),
      ],
    );
  }

  Widget _options<T>(
    BuildContext context, {
    required List<T> values,
    required T selected,
    required void Function(T) onSelect,
    required String Function(T) formatter,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((e) {
        final isActive = e == selected;

        return ChoiceChip(
          label: Text(
            formatter(e),
            style: context.typography.lgBold.copyWith(
              color: isActive ? AppColors.white : AppColors.textDisplay,
            ),
          ),
          selected: isActive,
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.background_neutral_25,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (_) => onSelect(e),
        );
      }).toList(),
    );
  }
}
