import 'package:diwanclinic/Presentation/screens/reservations/list/widgets/appbars/AppBarStatusDropdown.dart';
import 'package:diwanclinic/Presentation/screens/reservations/list/widgets/appbars/CalendarDropdown.dart';
import 'package:intl/intl.dart';
import '../../../../../../index/index_main.dart';

class ReservationDateAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final ReservationViewModel controller;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onFilterTap;
  final bool isGrid;

  const ReservationDateAppBar({
    super.key,
    required this.controller,
    this.onNotificationTap,
    this.onFilterTap,
    required this.isGrid,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 92.h,
      // Bigger, more breathable
      centerTitle: false,
      titleSpacing: 0,

      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
          ),

          child: Row(
            children: [
              //
              // ░░ Left : Date Selector ░░
              Expanded(
                flex: 5,
                child: CalendarDropdown(
                  controller: controller,
                  initialTimestamp:
                      controller.create_at ??
                      DateTime.now().millisecondsSinceEpoch,
                  onDateSelected: (timestamp, formattedDate) {
                    final d = timestamp.toDate();
                    controller.create_at = d.millisecondsSinceEpoch;
                    controller.appointment_date_time = DateFormat(
                      'dd/MM/yyyy',
                    ).format(d);

                    controller.getReservations(is_filter: true);
                    controller.update();
                  },
                ),
              ),
              // const SizedBox(width: 10),

              // // ░░ Right : Type Selector ░░
              // Expanded(
              //   flex: 4,
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(horizontal: 3.0.w),
              //     child: AppBarTypeDropdown(controller: controller),
              //   ),
              // ),
              const SizedBox(width: 10),

              // ░░ Notifications Icon (Optional) ░░
              // if (onNotificationTap != null)
              //   GestureDetector(
              //     onTap: onNotificationTap,
              //     child: Container(
              //       padding: const EdgeInsets.all(8),
              //       decoration: BoxDecoration(
              //         color: AppColors.primary.withValues(alpha: 0.1),
              //         shape: BoxShape.circle,
              //       ),
              //       child: SvgPicture.asset(
              //         IconsConstants.doc,
              //         height: 35.h,
              //         width: 35.w,
              //       ),
              //     ),
              //   ),
              // const SizedBox(width: 10),
              if (onFilterTap != null)
                GestureDetector(
                  onTap: onFilterTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isGrid ? Icons.grid_view_rounded : Icons.list_alt_rounded,
                      size: 28,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      // Divider Line
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1.2,
          color: AppColors.borderNeutralPrimary.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(92.h);
}
