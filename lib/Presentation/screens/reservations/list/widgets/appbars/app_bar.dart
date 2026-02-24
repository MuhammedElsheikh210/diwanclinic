import 'package:diwanclinic/Presentation/screens/reservations/list/widgets/appbars/CalendarDropdown.dart';
import 'package:intl/intl.dart';
import '../../../../../../index/index_main.dart';

class ReservationDateAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final ReservationViewModel controller;
  final VoidCallback? onFilterTap;
  final bool isGrid;

  const ReservationDateAppBar({
    super.key,
    required this.controller,
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
      centerTitle: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // ░░ Date Selector ░░
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
                    controller.appointmentDate = DateFormat(
                      'dd/MM/yyyy',
                    ).format(d);

                    controller.getReservations(isFilter: true);
                    controller.update();
                  },
                ),
              ),

              const SizedBox(width: 10),

              // ░░ Shift Badge ░░
              if (!controller.hideShiftSelector &&
                  controller.selectedShift != null)
                GestureDetector(
                  onTap: () {
                    controller.showMandatoryShiftDialog();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          controller.selectedShift?.name ?? "",
                          style: context.typography.smMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(width: 10),

              // ░░ Grid/List Toggle ░░
              if (onFilterTap != null)
                GestureDetector(
                  onTap: onFilterTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
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
          color: AppColors.borderNeutralPrimary.withOpacity(0.7),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(92.h);
}
