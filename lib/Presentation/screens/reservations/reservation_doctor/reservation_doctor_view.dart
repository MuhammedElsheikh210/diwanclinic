import 'package:diwanclinic/Presentation/screens/reservations/list/widgets/filter_chip_widget.dart';
import 'package:diwanclinic/Presentation/screens/reservations/reservation_doctor/widgets/ReservationDoctorAppBar.dart';
import 'package:diwanclinic/Presentation/screens/reservations/reservation_doctor/widgets/reservation_doctor_card.dart';
import 'package:diwanclinic/index/index_main.dart';

class ReservationDoctorView extends StatefulWidget {
  const ReservationDoctorView({super.key});

  @override
  State<ReservationDoctorView> createState() => _ReservationDoctorViewState();
}

class _ReservationDoctorViewState extends State<ReservationDoctorView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReservationDoctorViewModel>(
      init: ReservationDoctorViewModel(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,

          appBar: ReservationDoctorAppBar(controller: controller),
          body: Container(
            color: AppColors.white,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              children: [
                _buildStats(controller, context),
                SizedBox(height: 15.h),

                //  if (controller.hasActiveFilters)
                //  _buildActiveFilters(context, controller),
                _buildReservationList(controller, context),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // 📊 Stats
  // ─────────────────────────────────────────────
  Widget _buildStats(
    ReservationDoctorViewModel controller,
    BuildContext context,
  ) {
    final total = controller.totalCount;
    final completed = controller.completedCount;
    final pending = controller.pendingCount;

    return Row(
      children: [
        _statCard(
          context,
          "إجمالي",
          total.toString(),
          Icons.event_available,
          AppColors.primary,
        ),
        _statCard(
          context,
          "مكتملة",
          completed.toString(),
          Icons.check_circle,
          AppColors.successForeground,
        ),
        _statCard(
          context,
          "منتظرة",
          pending.toString(),
          Icons.access_time,
          AppColors.tag_icon_warning,
        ),
      ],
    );
  }

  Widget _buildActiveFilters(
    BuildContext context,
    ReservationDoctorViewModel controller,
  ) {
    final clinicsCount = controller.list_clinic?.length ?? 0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: controller.activeFilters.map((filter) {
            // 🚫 Hide clinic filter if doctor has only one clinic
            if (filter["label"].toString().contains("العيادة") &&
                clinicsCount <= 1) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: EdgeInsets.only(right: 6.w),
              child: FilterChipWidget(
                label: filter["label"],
                onRemove: filter["onRemove"],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 📋 Reservation List
  // ─────────────────────────────────────────────
  Widget _buildReservationList(
    ReservationDoctorViewModel controller,
    BuildContext context,
  ) {
    final list = controller.listReservations ?? [];

    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 100),
        child: Center(child: NoDataWidget(title: "لا يوجد حجوزات")),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: list.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final reservation = list[index];
        return Container(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ReservationDoctorCard(
            reservation: reservation!,
            controller: controller,
            index: index,
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // 🎨 Stat Card
  // ─────────────────────────────────────────────
  Widget _statCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 5),
            Column(
              children: [
                Text(
                  title,
                  style: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
                Text(
                  value,
                  style: context.typography.lgBold.copyWith(color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
