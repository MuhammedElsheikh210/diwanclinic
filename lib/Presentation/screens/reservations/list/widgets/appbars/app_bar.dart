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
      toolbarHeight: 120.h,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            /// 🔥 ROW 1 (DATE + VIEW BUTTON)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50.h,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CalendarDropdown(
                      controller: controller,
                      initialTimestamp:
                      controller.create_at ??
                          DateTime.now().millisecondsSinceEpoch,
                      onDateSelected: (timestamp, formattedDate) {
                        final d = timestamp.toDate();

                        controller.create_at = d.millisecondsSinceEpoch;
                        controller.appointmentDate =
                            DateFormat('dd-MM-yyyy').format(d);

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
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isGrid
                            ? Icons.grid_view_rounded
                            : Icons.list_alt_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            /// 🔥 ROW 2 (DOCTOR + SHIFT)
            Row(
              children: [
                /// 👨‍⚕️ DOCTOR
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
                      height: 44,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.06),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<LocalUser>(
                          isExpanded: true,
                          value: controller.selectedDoctor,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                          ),
                          items: controller.centerDoctors
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

                if (controller.isCenterMode)
                  const SizedBox(width: 8),

                /// ⏰ SHIFT
                if (showShiftSelector)
                  GestureDetector(
                    onTap: controller.showMandatoryShiftDialog,
                    child: Container(
                      height: 44,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(.06),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 16,
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
        child: Container(
          height: 1,
          color: Colors.grey.withOpacity(.15),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(120.h);
}