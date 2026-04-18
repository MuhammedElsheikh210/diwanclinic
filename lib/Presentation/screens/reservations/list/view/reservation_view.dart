import 'package:diwanclinic/index/index_main.dart';

class ReservationView extends StatefulWidget {
  const ReservationView({super.key});

  @override
  State<ReservationView> createState() => _ReservationViewState();
}

class _ReservationViewState extends State<ReservationView> {
  bool isGrid = true;
  late final ReservationViewModel controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = initController(() => ReservationViewModel());
    controller.appointmentDate = DatesUtilis.todayAsString();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReservationViewModel>(
      builder: (controller) {
        final reservations = controller.listReservations;

        return Scaffold(
          backgroundColor: ColorResources.COLOR_white,

          appBar: ReservationDateAppBar(
            controller: controller,

            onFilterTap: () {
              setState(() => isGrid = !isGrid);
            },
            isGrid: isGrid,
          ),

          body: Container(
            color: AppColors.white,
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.getReservations();
                controller.update();
              },
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
                children: [
                  isGrid
                      ? const SizedBox()
                      : ReservationReportWidget(controller: controller),

                  isGrid ? const SizedBox() : const SizedBox(height: 10),

                  isGrid
                      ? const SizedBox()
                      : StatsSection(controller: controller),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: _buildTabs(controller),
                  ),

                  isGrid
                      ? _buildReservationNotebook(reservations, controller)
                      : _buildReservationList(
                        reservations,
                        controller,
                        context,
                      ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: ColorResources.COLOR_Primary,
            child: const Icon(Icons.add, color: Colors.white, size: 28),

            onPressed: () async {
              final trueTotal = await controller.getTotalTodayReservations();
              final userType = Get.find<UserSession>().user?.user.userType;

              if (userType == UserType.patient) {
                Get.delete<CreateReservationFromPatientViewModel>();
                Get.to(
                  () => CreateReservationFromPatientView(
                    clinic_key: controller.selectedClinic?.key,
                    shift_key: controller.selectedShift?.key,
                    total_reservations: trueTotal,
                    selectedClinic: controller.selectedClinic,
                  ),
                );
              } else {
                Get.delete<CreateReservationViewModel>();
                Get.to(
                  () => CreateReservationView(
                    list_reservations: controller.listReservations ?? [],
                    dailly_date: controller.appointmentDate ?? "",
                    clinic_key: controller.selectedClinic?.key,
                    shift_key: controller.selectedShift?.key,
                    selected_clinic: controller.selectedClinic ?? ClinicModel(),
                    doctor_key: controller.selectedDoctor?.uid,
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------
  // 🔥 TABS UI — Now tied to SQLite filtering via controller.selectedTab
  // ---------------------------------------------------------------
  Widget _buildTabs(ReservationViewModel controller) {
    return Container(
      height: 55,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background_neutral_100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _TabItem(
            label: "كل الحجوزات",
            isSelected: controller.selectedTab == 0,
            onTap: () {
              controller.selectedTab = 0;
              controller.getReservations();
              controller.update();
              setState(() {});
            },
          ),
          _TabItem(
            label: "عاجل فقط",
            isSelected: controller.selectedTab == 1,
            onTap: () {
              controller.selectedTab = 1;
              controller.getReservations();
              controller.update();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReservationNotebook(
    List<ReservationModel?>? reservations,
    ReservationViewModel controller,
  ) {
    if (reservations?.isEmpty ?? true) {
      return const Padding(
        padding: EdgeInsets.only(top: 100),
        child: Center(child: NoDataWidget(title: "لا يوجد حجوزات")),
      );
    }

    return Column(
      children: List.generate(reservations!.length, (index) {
        final reservation = reservations[index]!;

        final status = ReservationStatusNewExt.fromValue(
          reservation.status ?? "",
        );

        final ahead = controller.queueManager.aheadInQueue(
          reservations: controller.listReservations,
          target: reservation,
        );

        final bool isFinished =
            status == ReservationNewStatus.completed ||
            status == ReservationNewStatus.cancelledByAssistant;

        final bool isActive =
            status == ReservationNewStatus.inProgress || ahead <= 0;

        return InkWell(
          onTap: () {
            Get.to(
              () => ReservationAssistantDetailsView(
                reservation: reservation,
                controller: controller,
                index: 0,
              ),
              binding: Binding(),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    isActive
                        ? AppColors.successForeground.withValues(alpha: 0.5)
                        : AppColors.borderNeutralPrimary.withValues(alpha: 0.2),
                width: isActive ? 1.5 : 1,
              ),
              boxShadow:
                  isFinished
                      ? []
                      : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
            ),

            child: reservationCard(
              context: context,
              reservation: reservation,
              status: status,
              controller: controller,
              ahead: ahead,
              isFinished: isFinished,
            ),
          ),
        );
      }),
    );
  }

  Widget reservationCard({
    required BuildContext context,
    required ReservationModel reservation,
    required ReservationNewStatus status,
    required ReservationViewModel controller,
    required int ahead,
    required bool isFinished,
  }) {
    final isActive = !isFinished;

    /// 🔥 FIX: detect cancel
    final isCancelled = (reservation.status ?? "").toLowerCase().contains(
      "cancelled",
    );

    /// 🔥 FIX: smart status text
    String getStatusText() {
      if (reservation.status == "completed") return "تم الكشف";

      if (isCancelled) return "تم إلغاء الحجز";

      if (ahead <= 0) return "دورك الآن";

      return "قدامك $ahead";
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:
            isFinished
                ? AppColors.background.withValues(alpha: 0.5)
                : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border:
            isFinished
                ? null
                : Border.all(color: AppColors.borderNeutralPrimary, width: 1),
      ),
      child: Row(
        children: [
          /// 🔢 Order Number
          Container(
            width: 40.w,
            height: 40.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  isActive
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Text(
              "${reservation.orderNum ?? '-'}",
              style: context.typography.mdRegular.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(width: 14),

          /// 🧾 Main Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.patientName ?? "",
                  style: context.typography.lgBold.copyWith(
                    fontWeight: FontWeight.w700,
                    color:
                        isActive
                            ? AppColors.background_black
                            : AppColors.textSecondaryParagraph,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        reservation.reservationType ?? "",
                        style: context.typography.xsMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "•",
                      style: context.typography.smRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${reservation.paidAmount ?? 0} ج.م",
                      style: context.typography.smMedium.copyWith(
                        color:
                            isActive
                                ? AppColors.background_black
                                : AppColors.textSecondaryParagraph,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          /// 🚀 Right Side
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              /// 🔥 FIX: Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      isCancelled
                          ? Colors.red.withValues(alpha: 0.1)
                          : isFinished
                          ? AppColors.successBackground.withValues(alpha: 0.3)
                          : AppColors.successBackground.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  getStatusText(),
                  style: context.typography.mdBold.copyWith(
                    color:
                        isCancelled
                            ? Colors.red
                            : ahead <= 0
                            ? AppColors.successForeground
                            : AppColors.textSecondaryParagraph,
                  ),
                ),
              ),

              /// 🎯 Action Button
              if (isActive)
                _primaryActionButton(
                  context,
                  status: status,
                  reservation: reservation,
                  controller: controller,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _primaryActionButton(
    BuildContext context, {
    required ReservationNewStatus status,
    required ReservationModel reservation,
    required ReservationViewModel controller,
  }) {
    Future<void> _handleAction({
      required ReservationStatus newStatus,
      String? cancelReason,
    }) async {
      try {
        await controller.changeReservationStatus(
          reservation: reservation,
          newStatus: newStatus,
          cancelReason: cancelReason,
        );
      } catch (e) {
        
      }
    }

    switch (status) {
      case ReservationNewStatus.pending:
        return _mainBtn(
          text: "تأكيد",
          color: AppColors.successForeground,
          onTap: () => _handleAction(newStatus: ReservationStatus.approved),
        );

      case ReservationNewStatus.approved:
        return _mainBtn(
          text: "ابدأ الكشف",
          color: AppColors.primary,
          onTap: () => _handleAction(newStatus: ReservationStatus.inProgress),
        );

      case ReservationNewStatus.inProgress:
        return _mainBtn(
          text: "إنهاء",
          color: AppColors.background_black,
          onTap: () => _handleAction(newStatus: ReservationStatus.completed),
        );

      default:
        return const SizedBox();
    }
  }

  Widget _mainBtn({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 45.h,
      width: 100.w,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: context.typography.xsMedium.copyWith(color: AppColors.white),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // LIST VIEW
  // ---------------------------------------------------------------
  Widget _buildReservationList(
    List<ReservationModel?>? reservations,
    ReservationViewModel controller,
    BuildContext context,
  ) {
    if (reservations == null) {
      return buildReservationShimmerList();
    }

    if (reservations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 100),
        child: Center(child: NoDataWidget(title: "لا يوجد حجوزات")),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 5),

      itemCount: reservations.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),

      itemBuilder: (context, index) {
        final reservation = reservations[index];

        return InkWell(
          borderRadius: BorderRadius.circular(12),

          onTap: () {
            if (Get.find<UserSession>().user?.user.userType?.name !=
                Strings.assistant) {
              Get.to(
                () => PatientForAssistantProfileView(
                  reservationModel: reservation ?? ReservationModel(),
                ),
                binding: Binding(),
              );
            }
          },

          child: Container(
            decoration: BoxDecoration(
              color: ColorResources.COLOR_white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 5.h),

            child: ReservationCard(
              reservation: reservation ?? ReservationModel(),
              controller: controller,
              index: index,
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------
  // SHIMMER
  // ---------------------------------------------------------------
  Widget buildReservationShimmerList() {
    const int shimmerCount = 6;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 10),
      itemCount: shimmerCount,
      itemBuilder: (_, __) => const ReservationCardShimmer(),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: context.typography.mdMedium.copyWith(
              color:
                  isSelected
                      ? AppColors.primary
                      : AppColors.textSecondaryParagraph,
            ),
          ),
        ),
      ),
    );
  }
}
