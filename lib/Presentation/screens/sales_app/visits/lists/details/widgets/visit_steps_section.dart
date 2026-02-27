import '../../../../../../../index/index_main.dart';

class VisitStepsSection extends StatelessWidget {
  final VisitDetailsViewModel controller;

  const VisitStepsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final visit = controller.currentVisit;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 عنوان القسم
          Text("خطوات التنفيذ", style: context.typography.mdBold),

          SizedBox(height: 16.h),

          /// Step 1
          _stepTile(
            context,
            title: "تدريب المساعد بالديمو",
            value: visit.step1TrainAssistantDemo,
            onChanged: (v) => controller.toggleStep1(v),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: visit.step1TrainAssistantDemo
                ? Padding(
                    padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
                    child: Column(
                      children: [
                        _inputField(
                          label: "اسم المساعد",
                          initial: visit.assistantName,
                          onChanged: (value) {
                            controller.currentVisit = controller.currentVisit
                                .copyWith(assistantName: value);
                          },
                        ),
                        SizedBox(height: 10.h),
                        _inputField(
                          label: "رقم المساعد",
                          initial: visit.assistantPrivatePhone,
                          keyboardType: TextInputType.phone,
                          onChanged: (value) {
                            controller.currentVisit = controller.currentVisit
                                .copyWith(assistantPrivatePhone: value);
                          },
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ),

          SizedBox(height: 12.h),

          /// Step 2
          _stepTile(
            context,
            title: "عرض تقديمي للطبيب",
            value: visit.step2DoctorPresentation,
            onChanged: (v) => controller.toggleStep2(v),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: visit.step2DoctorPresentation
                ? Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: _inputField(
                      label: "واتساب الطبيب",
                      initial: visit.doctorPrivateWhatsapp,
                      onChanged: (value) {
                        controller.currentVisit = controller.currentVisit
                            .copyWith(doctorPrivateWhatsapp: value);
                      },
                    ),
                  )
                : const SizedBox(),
          ),

          SizedBox(height: 12.h),

          /// Step 3
          _stepTile(
            context,
            title: "تدريب المساعد عملياً",
            value: visit.step3TrainAssistant,
            onChanged: (v) => controller.toggleStep3(v),
          ),

          SizedBox(height: 12.h),

          /// Step 4
          _stepTile(
            context,
            title: "إنشاء حساب للطبيب",
            value: visit.step4CreateAccount,
            onChanged: (v) => controller.toggleStep4(v),
          ),
        ],
      ),
    );
  }

  /// 🔹 تصميم Step احترافي
  Widget _stepTile(
    BuildContext context, {
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: value
              ? AppColors.primary.withOpacity(0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: value ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_circle : Icons.radio_button_unchecked,
              color: value ? AppColors.primary : Colors.grey,
            ),
            SizedBox(width: 10.w),
            Expanded(child: Text(title, style: context.typography.smMedium)),
          ],
        ),
      ),
    );
  }

  /// 🔹 Input Field موحد
  Widget _inputField({
    required String label,
    String? initial,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initial,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
