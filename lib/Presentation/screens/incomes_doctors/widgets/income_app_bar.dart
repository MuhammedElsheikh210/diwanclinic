import 'package:diwanclinic/Presentation/screens/incomes_doctors/income_doctor_view_model.dart';
import 'package:diwanclinic/Presentation/screens/incomes_doctors/widgets/calendar_dropdown_income.dart';
import 'package:diwanclinic/Presentation/screens/reservations/reservation_doctor/widgets/CalendarDropdownDoctor.dart';

import '../../../../../index/index_main.dart';

class IncomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final IncomeViewModel controller;

  const IncomeAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 85.h,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: CalendarDropdownIncome(
          initialTimestamp:
              controller.selectedDay ?? DateTime.now().millisecondsSinceEpoch,
          onDateSelected: (timestamp, formattedDate) {
            controller.getDataByDay(timestamp, formattedDate);
          },
        ),
      ),

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1.3, color: AppColors.borderNeutralPrimary),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(85.h);
}
