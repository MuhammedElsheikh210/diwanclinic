import '../../../../index/index_main.dart';

class PricingSearchView extends StatefulWidget {
  final OrderModel orderModel;

  const PricingSearchView({super.key, required this.orderModel});

  @override
  State<PricingSearchView> createState() => _PricingSearchViewState();
}

class _PricingSearchViewState extends State<PricingSearchView> {
  late final PricingSearchController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => PricingSearchController());
    controller.initWithOrder(widget.orderModel);
    controller.update();
  }

  @override
  Widget build(BuildContext context) {
    final HandleKeyboardService keyboardService = HandleKeyboardService();
    final keys = keyboardService.generateKeys('pricing', 10);

    return GetBuilder<PricingSearchController>(
      init: controller,
      builder: (c) {
        return Scaffold(
          backgroundColor: AppColors.background,

          // ───────────── AppBar ─────────────
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
            title: Text(
              "تسعير الروشتة",
              style: context.typography.lgBold.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),

          // ───────────── Body (SCROLLABLE) ─────────────
          body: SafeArea(
            child: KeyboardActions(
              config: keyboardService.buildConfig(context, keys),

              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ───────── Prescription Viewer ─────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: PrescriptionGallery([
                            widget.orderModel.prescriptionUrl1 ?? "",
                            widget.orderModel.prescriptionUrl2 ?? "",
                            widget.orderModel.prescriptionUrl3 ?? "",
                            widget.orderModel.prescriptionUrl4 ?? "",
                            widget.orderModel.prescriptionUrl5 ?? "",
                          ]),
                        ),
                      ),
                    ),

                    // ───────── Add Medicine ─────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PrimaryTextButton(
                        appButtonSize: AppButtonSize.xlarge,
                        label: AppText(
                          text: "إضافة دواء",
                          textStyle: context.typography.mdMedium,
                        ),
                        onTap: () {
                          Get.to(
                            () => MedicineSearchView(
                              onSelect: (medicine) {
                                c.addMedicine(medicine);
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ───────── Selected Medicines ─────────
                    if (c.selectedMedicines.isEmpty)
                      _EmptyMedicinesHint(context)
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: c.selectedMedicines.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final e = entry.value;

                            return _SelectedMedicineCard(
                              item: e,
                              focusNode: keyboardService.getFocusNode(
                                keys[index],
                              ),
                              onIncrease: () => c.increaseQty(e),
                              onDecrease: () => c.decreaseQty(e, context),
                            );
                          }).toList(),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ───────── Pricing Summary (NORMAL SECTION) ─────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: PricingSummary(
                        controller: c,
                        orderModel: widget.orderModel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SelectedMedicineCard extends StatelessWidget {
  final SelectedMedicine item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final FocusNode focusNode; // 👈

  const _SelectedMedicineCard({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // 💊 Icon
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication, color: AppColors.primary),
          ),

          const SizedBox(width: 12),

          // 📄 Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.medicine.arabic ?? "",
                  style: context.typography.mdMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  "${item.medicine.price ?? 0} ج × ${item.quantity}",
                  style: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ],
            ),
          ),

          // ➕➖ Quantity
          Row(
            children: [
              QtyBtn("-", onDecrease),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "${item.quantity}",
                  style: context.typography.mdBold,
                ),
              ),
              QtyBtn("+", onIncrease),
            ],
          ),

          const SizedBox(width: 12),

          // // 💰 Total
          // Text(
          //   "${item.total.toStringAsFixed(1)} ج",
          //   style: context.typography.mdBold.copyWith(color: AppColors.primary),
          // ),
          SizedBox(
            width: 90,
            child: TextFormField(
              focusNode: focusNode,
              // 👈 مهم
              textInputAction: TextInputAction.done,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              initialValue: item.price.toStringAsFixed(1),
              textAlign: TextAlign.center,
              style: context.typography.mdBold.copyWith(
                color: AppColors.primary,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 8,
                ),
                filled: true,
                fillColor: AppColors.background_neutral_25,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.borderNeutralPrimary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              ],
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null) {
                  item.price = parsed;
                  Get.find<PricingSearchController>().update();
                }
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).unfocus(); // 👈 Done يقفل الكيبورد
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _EmptyMedicinesHint(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.medication_outlined, size: 72, color: Colors.grey),
        const SizedBox(height: 12),
        Text("لم يتم إضافة أي أدوية", style: context.typography.mdMedium),
        const SizedBox(height: 4),
        Text(
          "اضغط على «إضافة دواء» لبدء التسعير",
          style: context.typography.smRegular.copyWith(
            color: AppColors.textSecondaryParagraph,
          ),
        ),
      ],
    ),
  );
}
