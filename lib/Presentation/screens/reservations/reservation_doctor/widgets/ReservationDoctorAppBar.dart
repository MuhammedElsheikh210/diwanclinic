import 'package:diwanclinic/Global/Enums/reservation_status_new.dart';
import 'package:diwanclinic/Presentation/screens/reservations/reservation_doctor/widgets/AppBarStatusDropdownDoctor.dart';
import 'package:diwanclinic/Presentation/screens/reservations/reservation_doctor/widgets/CalendarDropdownDoctor.dart';
import 'package:intl/intl.dart';
import '../../../../../index/index_main.dart';

class ReservationDoctorAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final ReservationDoctorViewModel controller;

  const ReservationDoctorAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 92.h,
      titleSpacing: 0,

      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// DATE PICKER
            Expanded(
              flex: 4,
              child: CalendarDropdownDoctor(
                controller: controller,
                initialTimestamp:
                controller.create_at?.toInt() ??
                    DateTime.now().millisecondsSinceEpoch,
                onDateSelected: (timestamp, formattedDate) {
                  controller.create_at = timestamp;
                  controller.appointment_date_time = formattedDate;

                  controller.getReservations(is_filter: true);
                  controller.getSyncReservations();
                  controller.update();
                },
              ),
            ),

            const SizedBox(width: 10),

            /// STATUS DROPDOWN
            Expanded(
              flex: 4,
              child: AppBarStatusDropdownDoctor(controller: controller),
            ),

            const SizedBox(width: 10),

            /// FILTER ICON
            InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const FilterViewReservation(),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  IconsConstants.filter,
                  height: 22,
                  width: 22,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
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
          height: 1.3,
          color: AppColors.borderNeutralPrimary,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(92.h);
}
