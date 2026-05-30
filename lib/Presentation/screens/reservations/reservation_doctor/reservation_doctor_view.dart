import 'package:diwanclinic/Presentation/screens/reservations/reservation_doctor/widgets/ReservationDoctorAppBar.dart';
import 'package:diwanclinic/Presentation/screens/reservations/reservation_doctor/widgets/reservation_doctor_card.dart';
import 'package:diwanclinic/index/index_main.dart';

class ReservationDoctorView extends StatelessWidget {
  const ReservationDoctorView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReservationDoctorViewModel>(
      init: ReservationDoctorViewModel(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: ReservationDoctorAppBar(controller: controller),
          body: controller.listReservations == null
              ? const _LoadingBody()
              : _Body(controller: controller),
        );
      },
    );
  }
}

// ── Loading state ──────────────────────────────────────────
class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

// ── Main body ──────────────────────────────────────────────
class _Body extends StatelessWidget {
  final ReservationDoctorViewModel controller;

  const _Body({required this.controller});

  @override
  Widget build(BuildContext context) {
    final list = controller.listReservations ?? [];

    return ListView(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 20.h),
      children: [
        _StatsRow(controller: controller),
        SizedBox(height: 14.h),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 80),
            child: Center(child: NoDataWidget(title: 'لا توجد حجوزات')),
          )
        else
          ...list.map((r) => ReservationDoctorCard(
                reservation: r!,
                controller: controller,
                index: list.indexOf(r),
              )),
      ],
    );
  }
}

// ── Stats row — 3 inline pills ─────────────────────────────
class _StatsRow extends StatelessWidget {
  final ReservationDoctorViewModel controller;

  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatPill(
          label: 'الإجمالي',
          value: controller.totalCount,
          color: AppColors.primary,
          bg: AppColors.primary_light,
        ),
        SizedBox(width: 8.w),
        _StatPill(
          label: 'مكتمل',
          value: controller.completedCount,
          color: const Color(0xFF10B981),
          bg: const Color(0xFFECFDF5),
        ),
        SizedBox(width: 8.w),
        _StatPill(
          label: 'منتظر',
          value: controller.pendingCount,
          color: const Color(0xFFF59E0B),
          bg: const Color(0xFFFFFBEB),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final Color bg;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: context.typography.lgBold.copyWith(color: color),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: context.typography.xsRegular.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
