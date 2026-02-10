import 'package:diwanclinic/index/index_main.dart';

class ReservationPatientView extends StatefulWidget {
  const ReservationPatientView({super.key});

  @override
  State<ReservationPatientView> createState() => _ReservationPatientViewState();
}

class _ReservationPatientViewState extends State<ReservationPatientView> {
  late final ReservationPatientViewModel controller;

  @override
  void initState() {
    controller = initController(() => ReservationPatientViewModel());
    controller.getReservations();
    controller.setupDefaultDate();
    controller.update();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReservationPatientViewModel>(
      init: controller,
      builder: (controller) {
        final reservations = controller.sortedReservations ?? [];
        print("reservations is ${reservations.length}");

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: const HomePatientAppBar(),

          body: Container(
            color: AppColors.white,
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                controller.getReservations();
                await controller.setupDefaultDate();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                children: [
                  // Optional: daily stats summary
                  // _buildStats(controller, context),
                  _buildReservationList(reservations, controller, context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildReservationList(
    List<ReservationModel?> reservations,
    ReservationPatientViewModel controller,
    BuildContext context,
  ) {
    if (reservations.isEmpty) {
      return Center(
        child: NoDataAnimated(
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
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: reservations.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 5.h),
          child: ReservationPatientCard(
            reservation: reservation ?? ReservationModel(),
            controller: controller,
            index: index,
            from_home: false,
          ),
        );
      },
    );
  }
}
