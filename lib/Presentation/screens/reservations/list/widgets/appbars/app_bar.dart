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
    final bool showShift =
        (controller.shiftDropdownItems?.length ?? 0) > 1 &&
        controller.selectedShift != null;

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      toolbarHeight: 110.h,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            /// 🔝 Top Row
            Row(
              children: [
                Expanded(child: _DatePill(controller: controller)),
                const SizedBox(width: 10),

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

            const SizedBox(height: 10),

            /// ⏰ Shift
            if (showShift)
              Align(
                alignment: Alignment.centerLeft,
                child: _ShiftPill(controller: controller),
              ),
          ],
        ),
      ),

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          color: AppColors.borderNeutralPrimary.withValues(alpha: .3),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(110.h);
}

class _BasePill extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double height;

  const _BasePill({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 14),
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(height: height, padding: padding, child: child),
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final ReservationViewModel controller;

  const _DatePill({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _BasePill(
      height: 52.h,
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 18,
            color: AppColors.primary,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: CalendarDropdown(
              controller: controller,
              initialTimestamp:
                  controller.create_at ?? DateTime.now().millisecondsSinceEpoch,
              onDateSelected: (timestamp, _) {
                final date = timestamp.toDate();

                controller.create_at = date.millisecondsSinceEpoch;

                // ✅ FIX
                controller.appointmentDate = DateFormat(
                  'dd-MM-yyyy',
                ).format(date);

                

                controller.getReservations();
                controller.update();
              },
            ),
          ),
        ],
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
      color: AppColors.primary.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 48,
          width: 48,
          child: Icon(icon, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _ShiftPill extends StatelessWidget {
  final ReservationViewModel controller;

  const _ShiftPill({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _BasePill(
      onTap: controller.showMandatoryShiftDialog,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 16, color: AppColors.primary),

          const SizedBox(width: 6),

          Text(
            controller.selectedShift?.name ?? "",
            style: context.typography.smMedium.copyWith(
              color: AppColors.background_black,
            ),
          ),

          const SizedBox(width: 4),

          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.textSecondaryParagraph,
          ),
        ],
      ),
    );
  }
}
