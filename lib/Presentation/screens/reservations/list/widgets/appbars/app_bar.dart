import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../index/index_main.dart';
import 'package:diwanclinic/Presentation/screens/reservations/list/widgets/appbars/CalendarDropdown.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../index/index_main.dart';
import 'package:diwanclinic/Presentation/screens/reservations/list/widgets/appbars/CalendarDropdown.dart';

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
    final hasShift = (controller.shiftDropdownItems?.isNotEmpty ?? false);
    final showShift = hasShift && (controller.shiftDropdownItems!.length > 1);

    return AppBar(
      backgroundColor: Colors.white,
      // ✅ نظيف
      elevation: 1,
      titleSpacing: 0,
      title: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// 🔝 DATE ROW
              Expanded(child: _DateCard(controller: controller)),
              const SizedBox(width: 7),

              /// ⏰ SHIFT (🔥 New Design)
              if (showShift)
                Align(
                  alignment: Alignment.center,
                  child: _ShiftSection(
                    controller: controller,
                    showDropdown: showShift,
                  ),
                ),
              const SizedBox(width: 7),

              if (onFilterTap != null)
                _IconButton(
                  icon:
                      isGrid
                          ? Icons.grid_view_rounded
                          : Icons.view_list_rounded,
                  onTap: onFilterTap!,
                ),
            ],
          ),
        ),
      ),

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.grey.withValues(alpha: .2)),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(75.h);
}

class _DateCard extends StatelessWidget {
  final ReservationViewModel controller;

  const _DateCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return CalendarDropdown(
      controller: controller,
      initialTimestamp:
          controller.create_at ?? DateTime.now().millisecondsSinceEpoch,
      onDateSelected: (timestamp, _) {
        final date = timestamp.toDate();

        controller.create_at = date.millisecondsSinceEpoch;
        controller.appointmentDate = DateFormat('dd-MM-yyyy').format(date);

        controller.getReservations();
        controller.update();
      },
    );
  }
}

class _ShiftSection extends StatelessWidget {
  final ReservationViewModel controller;
  final bool showDropdown;

  const _ShiftSection({required this.controller, required this.showDropdown});

  @override
  Widget build(BuildContext context) {
    final shiftName = controller.selectedShift?.name ?? "غير محدد";

    return GestureDetector(
      onTap: showDropdown ? controller.showMandatoryShiftDialog : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: .15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ⏰ icon
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.schedule,
                size: 13,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(width: 6),

            /// 📝 text
            Text(
              shiftName,
              style: context.typography.smMedium.copyWith(
                color: AppColors.textDefault,
              ),
            ),

            if (showDropdown) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: AppColors.textSecondaryParagraph,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 50,
          width: 50,
          child: Icon(icon, color: AppColors.primary),
        ),
      ),
    );
  }
}
