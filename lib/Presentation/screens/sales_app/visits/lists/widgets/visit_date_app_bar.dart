import 'package:diwanclinic/Presentation/screens/sales_app/visits/lists/widgets/calender_drop_down_visites.dart';
import '../../../../../../index/index_main.dart';

class VisitDateAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VisitViewModel controller;

  const VisitDateAppBar({super.key, required this.controller});

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
            /// ░░ Date Selector ░░
            Expanded(
              child: CalendarVisitesDropdown(
                initialTimestamp:
                    controller.selectedDate?.millisecondsSinceEpoch,
                onDateSelected: (timestamp, formattedDate) {
                  final d = timestamp.toDate();
                  controller.changeDate(d);
                },
              ),
            ),

            const SizedBox(width: 8),

            /// ░░ All Visits Button ░░
            GestureDetector(
              onTap: () {
                controller.showAllVisits();
              },
              child: _buildButton(
                context,
                icon: Icons.list_alt_rounded,
                title: "الكل",
                isActive: controller.selectedDate == null,
              ),
            ),
          ],
        ),
      ),

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1.2,
          color: AppColors.borderNeutralPrimary.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: context.typography.smMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(92.h);
}
