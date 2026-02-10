import 'dart:io';

import '../../../../index/index_main.dart';
import 'order_medicine_view_model.dart';

class OrderMedicineScreen extends StatelessWidget {
  final ReservationModel reservation;
  final Function(ReservationModel) onConfirmed;

  const OrderMedicineScreen({
    super.key,
    required this.reservation,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderMedicineViewModel>(
      init: OrderMedicineViewModel(reservation),
      builder: (vm) {
        return Scaffold(
          backgroundColor: AppColors.white,
          bottomNavigationBar: _bottomActionBar(context, vm),
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            title: AppText(
              text: "طلب العلاج",
              textStyle: context.typography.xlBold.copyWith(
                color: AppColors.textDisplay,
              ),
            ),
          ),
          body: Column(
            children: [
              _stepperHeader(context, vm),
              const Divider(height: 1),

              Expanded(
                child: vm.currentStep == 0
                    ? _uploadStep(context, vm)
                    : _confirmStep(context, vm),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bottomActionBar(BuildContext context, OrderMedicineViewModel vm) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 Hint text
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: AppText(
                text:
                    'الخدمة متاحة داخل طنطا فقط (القرى المجاورة غير مدعومة حاليًا)',
                textAlign: TextAlign.center,
                textStyle: context.typography.mdRegular.copyWith(
                  color: AppColors.background_black,
                  height: 1.4,
                ),
              ),
            ),

            SizedBox(
              width: ScreenUtil().screenWidth,
              child: PrimaryTextButton(
                appButtonSize: AppButtonSize.xxLarge,
                customBackgroundColor: _buttonColor(vm),
                onTap: _buttonAction(vm),
                label: AppText(
                  text: _buttonText(vm),
                  textAlign: TextAlign.center,
                  textStyle: context.typography.lgBold.copyWith(
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _buttonColor(OrderMedicineViewModel vm) {
    if (vm.currentStep == 0 && vm.selectedImages.isEmpty) {
      return AppColors.buttonDisabledColor;
    }
    return AppColors.primary;
  }

  VoidCallback? _buttonAction(OrderMedicineViewModel vm) {
    if (vm.currentStep == 0) {
      return vm.selectedImages.isEmpty ? null : vm.uploadImagesAndNext;
    }

    return () => vm.confirmOrder(onConfirmed);
  }

  String _buttonText(OrderMedicineViewModel vm) {
    if (vm.currentStep == 0) {
      return "التالي: تأكيد الطلب";
    }

    return "تأكيد الطلب";
  }

  // ===========================================================================
  // 🔷 STEPPER
  // ===========================================================================
  Widget _stepperHeader(BuildContext context, OrderMedicineViewModel vm) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.background_neutral_100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _stepItem(
              context,
              index: 1,
              title: "رفع الروشتة",
              isActive: vm.currentStep == 0,
              isDone: vm.currentStep > 0,
            ),
            const Expanded(child: Divider(thickness: 1)),
            _stepItem(
              context,
              index: 2,
              title: "تأكيد الطلب",
              isActive: vm.currentStep == 1,
              isDone: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepItem(
    BuildContext context, {
    required int index,
    required String title,
    required bool isActive,
    required bool isDone,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isDone || isActive
              ? AppColors.primary
              : Colors.grey.shade300,
          child: isDone
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : Text(
                  "$index",
                  style: context.typography.smSemiBold.copyWith(
                    color: Colors.white,
                  ),
                ),
        ),
        SizedBox(height: 6.h),
        Text(
          title,
          style: context.typography.xsMedium.copyWith(
            color: isActive
                ? AppColors.primary
                : AppColors.textSecondaryParagraph,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 🔶 STEP 1 – UPLOAD
  // ===========================================================================
  Widget _uploadStep(BuildContext context, OrderMedicineViewModel vm) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _uploadBanner(context),
          SizedBox(height: 20.h),
          _uploadArea(context, vm),
          const Spacer(),
        ],
      ),
    );
  }

  // ===========================================================================
  // 🔷 STEP 2 – CONFIRM (PROFESSIONAL)
  // ===========================================================================
  Widget _confirmStep(BuildContext context, OrderMedicineViewModel vm) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------
          // HEADER
          // --------------------------------------------------
          AppText(
            text: "تأكيد بيانات الطلب",
            textStyle: context.typography.lgBold.copyWith(
              color: AppColors.textDisplay,
            ),
          ),
          SizedBox(height: 4.h),
          AppText(
            text: "راجع البيانات التالية قبل إرسال الطلب للصيدلية",
            textStyle: context.typography.smRegular.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),

          SizedBox(height: 20.h),

          // --------------------------------------------------
          // CARD 1 — CONTACT INFO
          // --------------------------------------------------
          _card(
            context,
            title: "بيانات التواصل",
            child: Column(
              children: [
                _field("رقم الهاتف", vm.phoneController, context),
                _whatsAppSame(vm, context),
                if (!vm.isWhatsAppSame)
                  _field("رقم الواتساب", vm.whatsappController, context),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // --------------------------------------------------
          // CARD 2 — DELIVERY INFO
          // --------------------------------------------------
          _card(
            context,
            title: "بيانات التوصيل",
            child: Column(
              children: [
                _field("العنوان", vm.addressController, context, max: 2),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // --------------------------------------------------
          // CARD 3 — ADDITIONAL DETAILS
          // --------------------------------------------------
          _card(
            context,
            title: "تفاصيل إضافية",
            child: Column(
              children: [
                // _field(
                //   "عدد أيام الجرعة",
                //   vm.doseController,
                //   context,
                //   type: TextInputType.number,
                // ),
                _field(
                  "ملاحظات للصيدلية (اختياري)",
                  vm.notesController,
                  context,
                  max: 3,
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // --------------------------------------------------
          // INFO NOTE
          // --------------------------------------------------
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.background_neutral_100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.primary,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: AppText(
                    text:
                        "سيتم مراجعة الروشتة وتجهيز العلاج، ثم التواصل معك لتأكيد السعر والتوصيل.",
                    textStyle: context.typography.smRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.background_neutral_100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: title,
            textStyle: context.typography.mdBold.copyWith(
              color: AppColors.textDisplay,
            ),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    BuildContext context, {
    int max = 1,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: label,
            textStyle: context.typography.smMedium.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
          SizedBox(height: 6.h),
          AppTextField(
            controller: controller,
            maxLines: max,
            keyboardType: type,
          ),
        ],
      ),
    );
  }

  Widget _whatsAppSame(OrderMedicineViewModel vm, BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: vm.isWhatsAppSame,
          activeColor: AppColors.primary,
          onChanged: vm.toggleWhatsAppSame,
        ),
        AppText(
          text: "هذا هو رقم الواتساب",
          textStyle: context.typography.smMedium,
        ),
      ],
    );
  }

  Widget _uploadBanner(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, color: AppColors.primary),
          SizedBox(width: 10.w),
          Expanded(
            child: AppText(
              text: "ارفع الروشتة واطلب العلاج بخصم يصل إلى 10%",
              textStyle: context.typography.mdMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadArea(BuildContext context, OrderMedicineViewModel vm) {
    if (vm.selectedImages.isEmpty) {
      return GestureDetector(
        onTap: vm.pickImages,
        child: Container(
          height: 250.h,
          width: ScreenUtil().screenWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.borderNeutralPrimary,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: AppColors.primary,
              ),
              SizedBox(height: 12.h),
              AppText(
                text: "اضغط لرفع صور الروشتة",
                textStyle: context.typography.mdMedium,
              ),
              SizedBox(height: 4.h),
              AppText(
                text: "حتى 5 صور – واضحة ومن غير فلاش",
                textStyle: context.typography.xsRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: "الصور المرفوعة (${vm.selectedImages.length}/5)",
          textStyle: context.typography.smMedium,
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: vm.selectedImages.length,
          itemBuilder: (_, i) => ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(vm.selectedImages[i].path),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
