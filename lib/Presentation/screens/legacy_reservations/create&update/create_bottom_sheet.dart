import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class CreateLegacyQueueView extends StatelessWidget {
  final LegacyQueueModel? model;

  const CreateLegacyQueueView({super.key, this.model});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateLegacyQueueViewModel>(
      init: CreateLegacyQueueViewModel()..init(model),
      builder: (controller) {
        return Form(
          key: controller.formKey,
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔥 Header
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.event_note,
                          size: 40,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          controller.isUpdate
                              ? "تعديل اليوم"
                              : "إضافة يوم جديد",
                          style: context.typography.lgBold,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "حدد بيانات اليوم والفترة",
                          style: context.typography.smMedium.copyWith(
                            color: AppColors.textSecondaryParagraph,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 15.h),

                  /// 👨‍⚕️ Doctor Card
                  if (controller.isCenterMode)
                    _sectionCard(
                      title: "اختيار الدكتور",
                      child:
                          controller.isLoadingDoctors
                              ? const Center(child: CircularProgressIndicator())
                              : DropdownButtonHideUnderline(
                                child: DropdownButton<LocalUser>(
                                  isExpanded: true,
                                  value: controller.selectedDoctor,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                  ),
                                  items:
                                      controller.centerDoctors
                                          ?.where((e) => e != null)
                                          .map(
                                            (doc) => DropdownMenuItem(
                                              value: doc,
                                              child: Text(
                                                doc!.name ?? "",
                                                style:
                                                    context.typography.mdMedium,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (val) async {
                                    if (val == null) return;
                                    await controller.changeDoctor(val);
                                  },
                                ),
                              ),
                    ),

                  SizedBox(height: 10.h),

                  /// 📅 Date Card
                  _sectionCard(
                    title: "التاريخ",
                    child: CalenderWidget(
                      hintText: "اختر التاريخ",
                      initialTimestamp: controller.selectedTimestamp,
                      onDateSelected: (timestamp, date) {
                        controller.setDate(timestamp);
                      },
                    ),
                  ),

                  SizedBox(height: 10.h),

                  /// 🔢 Value Card
                  _sectionCard(
                    title: "عدد الحجوزات",
                    child: CustomInputField(
                      controller: controller.valueController,
                      keyboardType: TextInputType.number,
                      hintText: "مثال: 10",
                      focusNode: controller.valueFocusNode,
                      validator: controller.validateValue,
                      label: '',
                    ),
                  ),

                  SizedBox(height: 10.h),

                  /// ⏰ Shift Card
                  if (controller.shiftItems.isNotEmpty)
                    _sectionCard(
                      title: "الفترة",
                      child: GestureDetector(
                        onTap: () {
                          Get.dialog(
                            ShiftSelectionDialog(
                              shifts: controller.shiftItems,
                              initialSelected: controller.selectedShift,
                              onSelect: (shift) {
                                controller.selectShift(shift);
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.borderNeutralPrimary.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  controller.selectedShift?.name ??
                                      "اختر الفترة",
                                  style: context.typography.mdMedium.copyWith(
                                    color:
                                        controller.selectedShift == null
                                            ? AppColors.errorForeground
                                            : AppColors.textDisplay,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 15.h),

                  /// 💾 Save Button
                  SizedBox(
                    width: ScreenUtil().screenWidth,
                    child: PrimaryTextButton(
                      appButtonSize: AppButtonSize.xlarge,
                      label: AppText(
                        text: "حفظ",
                        textStyle: context.typography.mdMedium,
                      ),
                      onTap: controller.save,
                    ),
                  ),

                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🔥 Reusable Section Card
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.borderNeutralPrimary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
