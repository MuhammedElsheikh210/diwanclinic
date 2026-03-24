import '../../../../index/index_main.dart';

class CreateOpenclosereservationView extends StatelessWidget {
  final LegacyQueueModel? model;
  final String? shiftKey;

  const CreateOpenclosereservationView({super.key, this.model, this.shiftKey});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateOpenclosereservationViewModel>(
      init:
          CreateOpenclosereservationViewModel()
            ..init(model, incomingShiftKey: shiftKey),
      builder: (controller) {
        final bool isClosed = controller.isClosed;

        return Padding(
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔥 Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.event,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        controller.isUpdate ? "تعديل حالة اليوم" : "إضافة يوم",
                        style: context.typography.lgBold,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                /// 👨‍⚕️ Doctor
                if (controller.isCenterMode)
                  _card(
                    child:
                        controller.isLoadingDoctors
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownButtonHideUnderline(
                              child: DropdownButton<LocalUser>(
                                isExpanded: true,
                                value: controller.selectedDoctor,
                                icon: const Icon(Icons.keyboard_arrow_down),
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

                SizedBox(height: 16.h),

                /// 📅 Date
                _card(
                  child: CalenderWidget(
                    hintText: "اختر التاريخ",
                    initialTimestamp: controller.selectedTimestamp,
                    onDateSelected: (timeStamp, date) {
                      controller.setDate(timeStamp);
                    },
                  ),
                ),

                SizedBox(height: 16.h),

                /// ⏰ Shift
                if (controller.shiftDropdownItems != null &&
                    controller.shiftDropdownItems!.isNotEmpty)
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "الفترة",
                          style: context.typography.smMedium.copyWith(
                            color: AppColors.textSecondaryParagraph,
                          ),
                        ),
                        SizedBox(height: 10.h),

                        Wrap(
                          spacing: 10,
                          children:
                              controller.shiftDropdownItems!
                                  .map(
                                    (shift) => ChoiceChip(
                                      label: Text(shift.name ?? ""),
                                      selected:
                                          controller.selectedShift?.key ==
                                          shift.key,
                                      onSelected: (_) {
                                        controller.selectShift(shift);
                                      },
                                      selectedColor: AppColors.primary
                                          .withOpacity(0.15),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 20.h),

                /// 🔥 STATUS (🔥 BIG CHANGE)
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "حالة اليوم",
                        style: context.typography.smMedium.copyWith(
                          color: AppColors.textSecondaryParagraph,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      Row(
                        children: [
                          /// ✅ OPEN
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.toggleClosed(false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                decoration: BoxDecoration(
                                  color:
                                      !isClosed
                                          ? AppColors.primary.withOpacity(0.1)
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        !isClosed
                                            ? AppColors.primary
                                            : Colors.transparent,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "مفتوح",
                                    style: context.typography.mdMedium.copyWith(
                                      color:
                                          !isClosed
                                              ? AppColors.primary
                                              : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 10.w),

                          /// ❌ CLOSED
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.toggleClosed(true),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                decoration: BoxDecoration(
                                  color:
                                      isClosed
                                          ? AppColors.errorForeground
                                              .withOpacity(0.1)
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isClosed
                                            ? AppColors.errorForeground
                                            : Colors.transparent,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "مغلق",
                                    style: context.typography.mdMedium.copyWith(
                                      color:
                                          isClosed
                                              ? AppColors.errorForeground
                                              : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                /// 💾 Save
                SizedBox(
                  width: double.infinity,
                  child: PrimaryTextButton(
                    appButtonSize: AppButtonSize.xxLarge,
                    label: AppText(
                      text: "حفظ",
                      textStyle: context.typography.mdMedium,
                    ),
                    onTap: controller.save,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🔥 Card Wrapper
  Widget _card({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderNeutralPrimary.withOpacity(0.2),
        ),
      ),
      child: child,
    );
  }
}
