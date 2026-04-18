import 'package:diwanclinic/index/index_main.dart';

class ReservationPatientView extends StatefulWidget {
  const ReservationPatientView({super.key});

  @override
  State<ReservationPatientView> createState() => _ReservationPatientViewState();
}

class _ReservationPatientViewState extends State<ReservationPatientView>
    with SingleTickerProviderStateMixin {
  late final ReservationPatientViewModel controller;
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ReservationPatientViewModel());
    controller.setupDefaultDate();

    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReservationPatientViewModel>(
      init: controller,
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: const HomePatientAppBar(),

          body: SafeArea(
            child: Container(
              color: AppColors.white,
              child: Column(
                children: [
                  _buildProfessionalTabs(controller),
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        _buildTabList(controller.otherReservations),
                        _buildTabList(controller.completedReservations),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildProfessionalTabs(ReservationPatientViewModel controller) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
          height: 50.h,
          decoration: BoxDecoration(
            color: const Color(0xffE5E5E5),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              _tabItem(
                title: "الحالية (${controller.otherReservations.length})",
                index: 0,
              ),
              _tabItem(
                title: "المكتملة (${controller.completedReservations.length})",
                index: 1,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabItem({required String title, required int index}) {
    final bool isSelected = tabController.index == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          tabController.animateTo(index);
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildTabList(List<ReservationModel?> reservations) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await controller.setupDefaultDate();
      },
      child:
          reservations.isEmpty
              ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 150.h),
                  Center(
                    child: NoDataAnimated(
                      title: "لا توجد حجوزات",
                      subtitle: "لم تقم بأي حجز بعد",
                      lottiePath: Animations.no_prescription,
                      height: 200.h,
                      actionText: "إضافة حجز جديد",
                      onAction: () {
                        Get.to(() => const SpecializationView());
                      },
                    ),
                  ),
                ],
              )
              : ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: reservations.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final reservation = reservations[index];

                  return ReservationPatientCard(
                    reservation: reservation ?? ReservationModel(),
                    controller: controller,
                    index: index,
                    from_home: false,
                  );
                },
              ),
    );
  }
}
