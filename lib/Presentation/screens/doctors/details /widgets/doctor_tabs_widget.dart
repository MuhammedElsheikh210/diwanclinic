import 'package:flutter/material.dart';
import '../../../../../index/index_main.dart';

class DoctorTabsWidget extends StatelessWidget {
  final DoctorDetailsViewModel controller;

  const DoctorTabsWidget({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    final tabs = ["معلومات العيادة", "التقييمات", "تواصل معنا"];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowUpper.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.borderNeutralPrimary),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final bool isSelected = controller.selectedTabIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changeTab(index),
              behavior: HitTestBehavior.translucent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors
                            .primary // main active color
                      : AppColors.background_neutral_default,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary60
                        : AppColors.borderNeutralPrimary,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: isSelected
                        ? typography.mdBold.copyWith(color: AppColors.white)
                        : typography.mdMedium.copyWith(
                            color: AppColors.text_primary_paragraph,
                          ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
