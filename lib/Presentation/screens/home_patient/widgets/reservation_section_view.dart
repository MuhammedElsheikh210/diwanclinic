import '../../../../index/index_main.dart';

class ReservationSectionView extends StatelessWidget {
  final HomePatientController controller;

  const ReservationSectionView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final list = controller.activeReservations ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderSectionWidget(
          title: "حجوزاتي",
          onMore: () => Get.offAll(() => const MainPage(initialIndex: 1)),
        ),
        SizedBox(height: 14.h),

        if (list.isEmpty)
          NoDataAnimated(
            title: "لا توجد حجوزات",
            subtitle: "لم تقم بأي حجز بعد",
            lottiePath: Animations.no_prescription,
            height: 200.h,

            // ⭐ Action button
            actionText: "إضافة حجز جديد",

            // ⭐ Redirect to Specializations page
            onAction: () {
              Get.to(() => const SpecializationView());
            },
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              children: [
                // ─────────────────────────────────────
                // Reservation Cards
                // ─────────────────────────────────────
                ...List.generate(list.length, (i) {
                  final item = list[i];
                  if (item == null) return const SizedBox();

                  return Padding(
                    padding: EdgeInsets.only(right: 14.w),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.88,
                      child: ReservationPatientCard(
                        reservation: item,
                        controller: controller.reservationVM,
                        index: i,
                        from_home: true,
                      ),
                    ),
                  );
                }),

                // ─────────────────────────────────────
                // ➕ Add New Reservation Card
                // ─────────────────────────────────────
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
