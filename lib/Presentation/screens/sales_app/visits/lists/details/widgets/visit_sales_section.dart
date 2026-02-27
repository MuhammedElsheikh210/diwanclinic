import '../../../../../../../index/index_main.dart';
import 'package:intl/intl.dart';

class VisitSalesSection extends StatelessWidget {
  final VisitDetailsViewModel controller;

  const VisitSalesSection({
    super.key,
    required this.controller,
  });

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
          Text(
            "حالة البيع",
            style: context.typography.mdBold,
          ),

          SizedBox(height: 14.h),

          /// 🔹 Chips
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              _chip("تم الاتفاق", "deal", Colors.green),
              _chip("متابعة", "follow_up", Colors.orange),
              _chip("غير مهتم", "not_interested", Colors.red),
            ],
          ),

          /// 🔥 يظهر فقط لو Follow Up
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: visit.doctorSalesStatus == "follow_up"
                ? Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "موعد المتابعة",
                    style: context.typography.smMedium,
                  ),

                  SizedBox(height: 8.h),

                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        controller.updateFollowUp(picked);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.grayLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 18,
                              color: Colors.grey.shade600),
                          SizedBox(width: 8.w),
                          Text(
                            visit.followUpTimestamp != null
                                ? DateFormat(
                                'dd MMMM yyyy', 'ar')
                                .format(
                              DateTime.fromMillisecondsSinceEpoch(
                                visit.followUpTimestamp!,
                              ),
                            )
                                : "اختر تاريخ المتابعة",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _chip(
      String label,
      String value,
      Color color,
      ) {
    final isSelected =
        controller.currentVisit.doctorSalesStatus == value;

    return GestureDetector(
      onTap: () => controller.updateSalesStatus(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}