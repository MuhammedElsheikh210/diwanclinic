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
    final bool showShiftSelector =
        (controller.shiftDropdownItems?.length ?? 0) > 1 &&
        controller.selectedShift != null;

    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 130.h,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            /// ---------- ROW 1 (DATE + VIEW BUTTON) ----------
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 55.h,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CalendarDropdown(
                      controller: controller,
                      initialTimestamp:
                          controller.create_at ??
                          DateTime.now().millisecondsSinceEpoch,
                      onDateSelected: (timestamp, formattedDate) {
                        final d = timestamp.toDate();

                        controller.create_at = d.millisecondsSinceEpoch;
                        controller.appointmentDate = DateFormat(
                          'dd-MM-yyyy',
                        ).format(d);

                        controller.getReservations();
                        controller.update();
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                if (onFilterTap != null)
                  GestureDetector(
                    onTap: onFilterTap,
                    child: Container(
                      height: 50.h,
                      width: 50.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isGrid
                            ? Icons.grid_view_rounded
                            : Icons.list_alt_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            /// ---------- ROW 2 (DOCTOR + SHIFT) ----------
            Row(
              children: [
                /// DOCTOR
                if (controller.isCenterMode)
                  Expanded(
                    child:
                        controller.isLoadingDoctors
                            ? const SizedBox(
                              height: 44,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                            : Container(
                              height: 50.h,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<LocalUser>(
                                  isExpanded: true,
                                  value: controller.selectedDoctor,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                  ),
                                  items:
                                      controller.centerDoctors
                                          ?.where((e) => e != null)
                                          .map(
                                            (doc) => DropdownMenuItem(
                                              value: doc,
                                              child: Text(
                                                doc!.name ?? "",
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    context.typography.smMedium,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (val) async {
                                    controller.selectedDoctor = val;
                                    await controller.getClinicList();
                                    controller.update();
                                  },
                                ),
                              ),
                            ),
                  ),

                if (controller.isCenterMode) const SizedBox(width: 0),

                /// SHIFT
                if (showShiftSelector)
                  GestureDetector(
                    onTap: () {
                      controller.showMandatoryShiftDialog();
                    },
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(.08),
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
              ],
            ),
          ],
        ),
      ),

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey.withValues(alpha: .15)),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(130.h);
}
