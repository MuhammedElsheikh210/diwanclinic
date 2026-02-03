import 'package:intl/intl.dart';

import '../../../../../index/index_main.dart';

class PharmacyOrdersDateAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final PharmacyOrdersListViewModel controller;

  const PharmacyOrdersDateAppBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 92.h,
      centerTitle: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            // ░░ Date Picker ░░
            Expanded(
              child: InkWell(
                onTap: () => _showDatePicker(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.grayLight.withOpacity(0.4),
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
