import '../../../../index/index_main.dart';

class ReservationSectionView extends StatelessWidget {
  final HomePatientController controller;

  const ReservationSectionView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReservationPatientViewModel>(
      builder: (vm) {
        final activeList = vm.otherReservations;
        final pastList = vm.completedReservations;
        final hasActive = activeList.isNotEmpty;
        final hasPast = pastList.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderSectionWidget(
              title: "حجوزاتي",
              onMore: () {
                Get.find<MainPageViewModel>().changeIndex(1);
              },
            ),
            SizedBox(height: 14.h),

            if (hasActive)
              _HorizontalReservationList(
                list: activeList,
                vm: vm,
              )
            else if (hasPast)
              _PastReservationsSection(list: pastList, vm: vm)
            else
              NoDataAnimated(
                title: "لا توجد حجوزات",
                subtitle: "لم تقم بأي حجز بعد",
                lottiePath: Animations.no_prescription,
                height: 200.h,
                actionText: "إضافة حجز جديد",
                onAction: () {
                  Get.to(() => const SpecializationView());
                },
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Active reservations — horizontal scroll (original behaviour)
// ---------------------------------------------------------------------------
class _HorizontalReservationList extends StatelessWidget {
  final List<ReservationModel?> list;
  final ReservationPatientViewModel vm;

  const _HorizontalReservationList({required this.list, required this.vm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        children: [
          ...List.generate(list.length, (i) {
            final item = list[i];
            if (item == null) return const SizedBox();

            return Padding(
              padding: EdgeInsets.only(right: 14.w),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.88,
                child: ReservationPatientCard(
                  reservation: item,
                  controller: vm,
                  index: i,
                  from_home: true,
                ),
              ),
            );
          }),

          Padding(
            padding: EdgeInsets.only(right: 14.w),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.88,
              child: AddNewReservationCard(
                onTap: () => Get.to(() => const SpecializationView()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Past reservations — shown when no active reservation exists
// ---------------------------------------------------------------------------
class _PastReservationsSection extends StatelessWidget {
  final List<ReservationModel?> list;
  final ReservationPatientViewModel vm;

  const _PastReservationsSection({required this.list, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 16.w, left: 16.w, bottom: 10.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 14.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "حجوزات سابقة",
                      style: context.typography.mdMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            children: [
              ...List.generate(list.length, (i) {
                final item = list[i];
                if (item == null) return const SizedBox();

                return Padding(
                  padding: EdgeInsets.only(right: 14.w),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.88,
                    child: Opacity(
                      opacity: 0.85,
                      child: ReservationPatientCard(
                        reservation: item,
                        controller: vm,
                        index: i,
                        from_home: true,
                      ),
                    ),
                  ),
                );
              }),

              Padding(
                padding: EdgeInsets.only(right: 14.w),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.88,
                  child: AddNewReservationCard(
                    onTap: () => Get.to(() => const SpecializationView()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
