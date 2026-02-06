import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class OpenclosereservationDateAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final OpenclosereservationViewModel controller;

  const OpenclosereservationDateAppBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    /// 🧠 اليوم الحالي مقفول؟
    final bool isClosedDay = controller.list != null &&
        controller.list!.isNotEmpty &&
        controller.list!.first?.isClosed == true;

    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 92.h,
      centerTitle: false,
      titleSpacing: 0,
      leading: const BackButton(),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _showDatePicker(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isClosedDay
                          ? AppColors.errorForeground.withOpacity(0.6)
                          : AppColors.grayLight.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.formattedDate,
                        style: context.typography.lgBold.copyWith(
                          color: AppColors.textDisplay,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                      ),

                      /// 🔒 Closed badge
                      if (isClosedDay) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.errorForeground.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            "مغلق",
                            style: context.typography.xsMedium.copyWith(
                              color: AppColors.errorForeground,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.borderNeutralPrimary.withOpacity(0.6),
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    final calenderVM = Get.put(CalenderViewModel());

    calenderVM.showIOSDatePicker(
      context,
      controller.selectedDate.millisecondsSinceEpoch,
          (timestamp, formattedDate) {
        controller.onDateChanged(timestamp.toDate());
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(92.h);
}
