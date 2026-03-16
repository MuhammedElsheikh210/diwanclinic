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
    controller.getClinicList();
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
              final userType = LocalUser().getUserData().userType;

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
                    total_reservations: trueTotal,
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
      height: 42,
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

        // 🔹 نفس اللوجيك المستخدم في ReservationCard
        final status = ReservationStatusNewExt.fromValue(
          reservation.status ?? "",
        );
        final ahead = controller.queueManager.aheadInQueue(
          reservations: controller.listReservations,
          target: reservation,
        );

        final bool isCompletedOrCancelled =
            reservation.status == ReservationNewStatus.completed.value ||
            reservation.status ==
                ReservationNewStatus.cancelledByAssistant.value;

        // 🔹 نص الحالة
        String statusText;
        Color statusColor;

        if (status == ReservationNewStatus.completed) {
          statusText = "تم الكشف";
          statusColor = AppColors.primary;
        } else if (isCompletedOrCancelled) {
          statusText = "ملغي";
          statusColor = AppColors.errorForeground;
        } else if (status == ReservationNewStatus.inProgress) {
          statusText = "في الكشف";
          statusColor = AppColors.primary;
        } else if (status == ReservationNewStatus.pending) {
          statusText = "في انتظار التأكيد";
          statusColor = AppColors.tag_icon_warning;
        } else {
          statusText = ahead <= 0 ? "دورك الآن" : "قدّامك $ahead";
          statusColor = AppColors.textSecondaryParagraph;
        }

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
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color:
                  status == ReservationNewStatus.inProgress
                      ? AppColors.primary.withValues(alpha: 0.06)
                      : status == ReservationNewStatus.completed
                      ? AppColors.tag_icon_warning.withValues(alpha: 0.06)
                      : (status == ReservationNewStatus.approved && ahead <= 0)
                      ? AppColors.successBackground.withValues(alpha: 0.15)
                      : AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    status == ReservationNewStatus.inProgress
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.borderNeutralPrimary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔢 الرقم
                SizedBox(
                  width: 28.w,
                  child: Text(
                    "${reservation.order_num ?? '-'}",
                    style: context.typography.mdBold.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ),

                // 👤 الاسم + نوع الكشف
                // 👤 الاسم + نوع الكشف + الحالة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الاسم
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              reservation.patientName ?? "",
                              style: context.typography.mdMedium.copyWith(
                                color: AppColors.background_black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          Expanded(
                            child: Text(
                              "  ( ${reservation.reservationType ?? ""} )",
                              style: context.typography.smMedium.copyWith(
                                color: AppColors.textSecondaryParagraph,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // نوع الكشف • الحالة
                      Text(
                        "المدفوع  ${reservation.paidAmount ?? ""} ج.م ",
                        style: context.typography.smMedium.copyWith(
                          color: AppColors.textSecondaryParagraph,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔹 الحالة + الأزرار
                Column(
                  children: [
                    // الحالة
                    reservation.reservationType == "كشف مستعجل"
                        ? const SizedBox()
                        : Text(
                          statusText,
                          style: context.typography.smMedium.copyWith(
                            color: statusColor,
                          ),
                        ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🟡 pending → تأكيد / إلغاء
                        if (status == ReservationNewStatus.pending) ...[
                          GestureDetector(
                            onTap: () async {
                              await controller.changeReservationStatus(
                                reservation: reservation,
                                newStatus: ReservationStatus.approved,
                              );
                            },
                            child: _smallActionButton(
                              context,
                              text: "تأكيد",
                              color: AppColors.successForeground,
                            ),
                          ),
                        ],

                        // 🟢 approved → ابدأ الكشف
                        if (status == ReservationNewStatus.approved) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () async {
                              await controller.changeReservationStatus(
                                reservation: reservation,
                                newStatus: ReservationStatus.inProgress,
                              );
                            },
                            child: _smallActionButton(
                              context,
                              text: "ابدأ الكشف",
                              color: AppColors.primary,
                            ),
                          ),
                        ],

                        // 🔵 inProgress → إنهاء
                        if (status == ReservationNewStatus.inProgress) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () async {
                              await controller.changeReservationStatus(
                                reservation: reservation,
                                newStatus: ReservationStatus.completed,
                              );
                            },
                            child: _smallActionButton(
                              context,
                              text: "إنهاء الكشف",
                              color: AppColors.background_black,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _smallActionButton(
    BuildContext context, {
    required String text,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 0.7),
      ),
      child: Text(
        text,
        style: context.typography.mdMedium.copyWith(color: color),
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
            if (LocalUser().getUserData().userType?.name != Strings.assistant) {
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
