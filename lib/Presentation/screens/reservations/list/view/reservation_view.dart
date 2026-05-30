import 'package:diwanclinic/index/index_main.dart';

class ReservationView extends StatefulWidget {
  const ReservationView({super.key});

  @override
  State<ReservationView> createState() => _ReservationViewState();
}

class _ReservationViewState extends State<ReservationView> {
  bool isGrid = true;
  late final ReservationViewModel controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = initController(() => ReservationViewModel());
    controller.appointmentDate = DatesUtilis.todayAsString();
    _searchController.addListener(() {
      controller.searchQuery = _searchController.text;
      controller.update();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReservationViewModel>(
      init: controller,
      builder: (controller) {
        final reservations = controller.filteredReservations;

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
                  // Doctor status announcement banner
                  const DoctorStatusBanner(),

                  isGrid ? const SizedBox() : const SizedBox(height: 10),

                  isGrid
                      ? const SizedBox()
                      : StatsSection(controller: controller),

                  isGrid
                      ? const SizedBox()
                      : ReservationReportWidget(controller: controller),

                  // ── Pending reservations banner (assistant only) ──
                  const _PendingReservationsBanner(),

                  // ── Search bar ───────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 8.h,
                    ),
                    child: TextField(
                      controller: _searchController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      inputFormatters: [ArabicToEnglishDigitsFormatter()],
                      decoration: InputDecoration(
                        hintText: "بحث برقم الحجز أو رقم التلفون",
                        hintStyle: context.typography.smRegular.copyWith(
                          color: AppColors.textSecondaryParagraph,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                        ),
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    controller.searchQuery = "";
                                    controller.update();
                                  },
                                )
                                : null,
                        filled: true,
                        fillColor: AppColors.background_neutral_100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        controller.searchQuery = value;
                        controller.update();
                      },
                    ),
                  ),

                  // ── Tabs (فقط لو في كشف مستعجل جاري) ─────────
                  if (controller.hasActiveUrgentReservation)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.0.h),
                      child: _buildTabs(controller),
                    ),

                  _buildReservationNotebook(reservations, controller),
                ],
              ),
            ),
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const CreateAnnouncementFab(),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'add_reservation_fab',
                backgroundColor: ColorResources.COLOR_Primary,
                child: const Icon(Icons.add, color: Colors.white, size: 28),

                onPressed: () async {
                  final trueTotal =
                      await controller.getTotalTodayReservations();
                  final userType = Get.find<UserSession>().user?.user.userType;

                  if (userType == UserType.patient) {
                    Get.delete<CreateReservationFromPatientViewModel>();
                    Get.to(
                      () => CreateReservationFromPatientView(
                        clinic_key: controller.selectedClinic?.key,
                        shift_key: controller.selectedShift?.key,
                        total_reservations: trueTotal,
                        selectedClinic: controller.selectedClinic,
                        selectedDoctor: controller.selectedDoctor,
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
                        selected_clinic:
                            controller.selectedClinic ?? ClinicModel(),
                        doctor_key: controller.selectedDoctor?.uid,
                      ),
                    );
                  }
                },
              ),
            ],
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

        // Use orderReserved (set by buildFinalList) — stable across renders.
        // aheadInQueue() re-sorts on every frame → the number jumps the moment
        // the patient is marked checkedIn. orderReserved only updates when the
        // full list is rebuilt, so the display stays calm.
        final int ahead =
            (reservation.orderReserved != null)
                ? (reservation.orderReserved! - 1).clamp(0, 9999)
                : -1;

        final bool isFinished =
            status == ReservationNewStatus.completed ||
            status == ReservationNewStatus.missed ||
            status == ReservationNewStatus.cancelledByAssistant ||
            status == ReservationNewStatus.cancelledByUser;

        final bool isActive =
            status == ReservationNewStatus.inProgress ||
            status == ReservationNewStatus.checkedIn ||
            ahead <= 0;

        return GestureDetector(
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
          child: reservationCard(
            context: context,
            reservation: reservation,
            status: status,
            controller: controller,
            ahead: ahead,
            isFinished: isFinished,
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
    final isCancelled = (reservation.status ?? "").toLowerCase().contains(
      "cancelled",
    );
    final isCheckedIn = reservation.status == ReservationStatus.checkedIn.value;
    final isInProgress =
        reservation.status == ReservationStatus.inProgress.value;
    final isCompleted = reservation.status == ReservationStatus.completed.value;
    final isMissed = reservation.status == ReservationStatus.missed.value;
    final priority = ReservationPriorityExt.fromLevel(
      reservation.priorityLevel,
    );
    final hasHardPriority = reservation.isHardPriority;

    // ── Status meta ─────────────────────────────────────────
    Color statusColor() {
      if (isCancelled || isMissed) return const Color(0xFFEF4444);
      if (isCompleted) return const Color(0xFF10B981);
      if (isInProgress) return const Color(0xFF3B82F6);
      if (isCheckedIn) return AppColors.primary;
      if (hasHardPriority) return const Color(0xFFEF4444);
      if (ahead <= 0) return AppColors.primary;
      return AppColors.primary;
    }

    IconData statusIcon() {
      if (isCancelled) return Icons.cancel_outlined;
      if (isMissed) return Icons.person_off_outlined;
      if (isCompleted) return Icons.check_circle_outline_rounded;
      if (isInProgress) return Icons.medical_services_outlined;
      if (isCheckedIn) return Icons.how_to_reg_outlined;
      if (hasHardPriority) return Icons.priority_high_rounded;
      if (ahead <= 0) return Icons.notifications_active_outlined;
      return Icons.hourglass_top_rounded;
    }

    // Status pill shows ACTUAL status only.
    // Queue position (رقم + قبله) is shown in the combined badge (Row 1).
    String statusLabel() {
      if (isCompleted) return "تم الكشف";
      if (isMissed) return "تغيّب";
      if (isCancelled) return "تم الإلغاء";
      if (isInProgress) return "في الكشف الآن";
      if (isCheckedIn) return "حضر العيادة ✓";
      if (hasHardPriority) return "${priority.emoji} ${priority.label}";
      if (ahead <= 0) return "دورك الآن 🎯";
      return "";
    }

    final Color accentColor = statusColor();
    final bool dimmed = isCompleted || isCancelled || isMissed;

    return Opacity(
      opacity: dimmed ? 0.72 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accentColor.withValues(
              alpha: dimmed ? 0.20 : (hasHardPriority ? 0.75 : 0.45),
            ),
            width: hasHardPriority ? 2.5 : 1.8,
          ),
          boxShadow:
              dimmed
                  ? []
                  : hasHardPriority
                  ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.20),
                      blurRadius: 14,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── LEFT ACCENT STRIP ──────────────────────────
              Container(
                width: hasHardPriority ? 7 : 5,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),

              // ── MAIN CONTENT ───────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── ROW 1: name + order badge ───────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Patient name + phone
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reservation.patientName ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.typography.lgBold.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.background_black,
                                    fontSize: 22,
                                  ),
                                ),
                                if ((reservation.patientPhone ?? "").isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      reservation.patientPhone!,
                                      style: context.typography.smRegular
                                          .copyWith(
                                            color: const Color(0xFF374151),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          // ── Combined badge: رقم الحجز + قبله كام ──────
                          _orderQueueBadge(
                            context,
                            orderNum: reservation.orderNum,
                            ahead: ahead,
                            accentColor: accentColor,
                            showAhead:
                                !isCompleted &&
                                !isCancelled &&
                                !isMissed &&
                                !isInProgress,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ── ROW 2: type chip + amount ────────────
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _chip(
                            context,
                            label: reservation.reservationType ?? "",
                            bg: AppColors.primary.withValues(alpha: 0.15),
                            fg: AppColors.primary,
                          ),
                          if ((reservation.paidAmount ?? "0") != "0" &&
                              (reservation.paidAmount ?? "").isNotEmpty)
                            _chip(
                              context,
                              label: "${reservation.paidAmount} ج.م",
                              bg: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.18),
                              fg: const Color(0xFF059669),
                              icon: Icons.payments_outlined,
                            ),
                          if (hasHardPriority)
                            _chip(
                              context,
                              label: "${priority.emoji} ${priority.label}",
                              bg: const Color(
                                0xFFEF4444,
                              ).withValues(alpha: 0.18),
                              fg: const Color(0xFFDC2626),
                              icon: Icons.local_hospital_rounded,
                            ),
                          if (isCheckedIn)
                            _chip(
                              context,
                              label: "حضر",
                              bg: const Color(
                                0xFF0D9488,
                              ).withValues(alpha: 0.18),
                              fg: const Color(0xFF0D9488),
                              icon: Icons.how_to_reg_outlined,
                            ),
                          if (reservation.queueReason != null &&
                              !isCompleted &&
                              !isCancelled)
                            _chip(
                              context,
                              label:
                                  QueueChangeReasonExt.fromLabel(
                                    reservation.queueReason,
                                  ).assistantBadge,
                              bg: Colors.grey.withValues(alpha: 0.15),
                              fg: Colors.grey.shade800,
                              icon: Icons.swap_vert_rounded,
                            ),
                          if (reservation.paymentMethod != null &&
                              reservation.paymentMethod!.isNotEmpty)
                            _chip(
                              context,
                              label: () {
                                switch (reservation.paymentMethod) {
                                  case 'instapay':
                                    return 'طريقة الدفع: InstaPay';
                                  case 'wallet':
                                    return 'طريقة الدفع: محفظة';
                                  default:
                                    return 'طريقة الدفع: كاش';
                                }
                              }(),
                              bg: () {
                                switch (reservation.paymentMethod) {
                                  case 'instapay':
                                    return Colors.green.withValues(alpha: 0.12);
                                  case 'wallet':
                                    return Colors.blue.withValues(alpha: 0.12);
                                  default:
                                    return Colors.orange.withValues(alpha: 0.12);
                                }
                              }(),
                              fg: () {
                                switch (reservation.paymentMethod) {
                                  case 'instapay':
                                    return Colors.green.shade700;
                                  case 'wallet':
                                    return Colors.blue.shade700;
                                  default:
                                    return Colors.orange.shade700;
                                }
                              }(),
                              icon: () {
                                switch (reservation.paymentMethod) {
                                  case 'instapay':
                                    return Icons.payment;
                                  case 'wallet':
                                    return Icons.account_balance_wallet_outlined;
                                  default:
                                    return Icons.payments_outlined;
                                }
                              }(),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── DIVIDER ──────────────────────────────
                      Divider(
                        height: 1,
                        thickness: 1.2,
                        color: Colors.grey.withValues(alpha: 0.28),
                      ),

                      const SizedBox(height: 12),

                      // ── ROW 3: status pill + action ──────────
                      Row(
                        children: [
                          // Status pill
                          !isCompleted && !isCancelled && !isInProgress
                              ? const Spacer()
                              : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: accentColor.withValues(alpha: 0.40),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      statusIcon(),
                                      size: 17,
                                      color: accentColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      statusLabel(),
                                      style: context.typography.smMedium
                                          .copyWith(
                                            color: accentColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                    ),
                                  ],
                                ),
                              ),

                          const Spacer(),

                          // Action button(s)
                          // missed stays visually dimmed but still shows "رجع"
                          if (!isCompleted && !isCancelled)
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required Color bg,
    required Color fg,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: fg.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: context.typography.xsMedium.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
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
      } catch (e) {}
    }

    switch (status) {
      case ReservationNewStatus.pending:
        return _mainBtn(
          text: "تأكيد",
          color: AppColors.background_black,
          icon: Icons.check_rounded,
          onTap: () => _handleAction(newStatus: ReservationStatus.approved),
        );

      case ReservationNewStatus.approved:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _mainBtn(
              text: "ادخل للكشف",
              color: AppColors.primary,
              icon: Icons.play_arrow_rounded,
              onTap:
                  () => _handleAction(newStatus: ReservationStatus.inProgress),
            ),
            const SizedBox(width: 6),
            _mainBtn(
              text: "حضر",
              color: const Color(0xFF0D9488),
              icon: Icons.how_to_reg_rounded,
              onTap: () => controller.checkInPatient(reservation),
            ),
            const SizedBox(width: 6),

            _mainBtn(
              text: "غاب",
              color: const Color(0xFFF97316),
              icon: Icons.person_off_outlined,
              onTap: () => controller.markPatientMissed(reservation),
            ),
          ],
        );

      case ReservationNewStatus.checkedIn:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _mainBtn(
              text: "ابدأ الكشف",
              color: AppColors.primary,
              icon: Icons.play_arrow_rounded,
              onTap:
                  () => _handleAction(newStatus: ReservationStatus.inProgress),
            ),
            const SizedBox(width: 6),
            _mainBtn(
              text: "غاب",
              color: const Color(0xFFF97316),
              icon: Icons.person_off_outlined,
              onTap: () => controller.markPatientMissed(reservation),
            ),
          ],
        );

      case ReservationNewStatus.inProgress:
        return _mainBtn(
          text: "تم",
          color: const Color(0xFF10B981),
          icon: Icons.check_circle_outline_rounded,
          onTap: () => _handleAction(newStatus: ReservationStatus.completed),
        );

      case ReservationNewStatus.missed:
        return _mainBtn(
          text: "رجع",
          color: Colors.teal,
          icon: Icons.redo_rounded,
          onTap: () => controller.returnMissedPatient(reservation),
        );

      default:
        return const SizedBox();
    }
  }

  /// Combined badge: رقم الحجز + قبله كام in ONE chip.
  ///
  /// • [showAhead] = false  → show رقم only (completed / cancelled / missed / inProgress)
  /// • [ahead] == -1        → hide قبله section (patient not in active queue)
  /// • [ahead] == 0         → show "دورك"
  /// • [ahead]  > 0         → show "قبله $ahead"
  Widget _orderQueueBadge(
    BuildContext context, {
    required int? orderNum,
    required int ahead,
    required Color accentColor,
    required bool showAhead,
  }) {
    final orderText = (orderNum != null && orderNum != 0) ? "#$orderNum" : "—";

    final bool hasQueue = showAhead && ahead >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // رقم الحجز
          Text(
            orderText,
            style: context.typography.mdBold.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),

          // Separator + قبله كام
          if (hasQueue) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 1.5,
              height: 18,
              color: accentColor.withValues(alpha: 0.60),
            ),
            Text(
              ahead == 0 ? "دورك" : "قبله $ahead",
              style: context.typography.smMedium.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _mainBtn({
    required String text,
    required Color color,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return SizedBox(
      height: 50.h,
      child: ElevatedButton.icon(
        icon:
            icon != null
                ? Icon(icon, size: 18, color: Colors.white)
                : const SizedBox.shrink(),
        label: Text(
          text,
          style: context.typography.mdBold.copyWith(color: AppColors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onTap,
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

// ─────────────────────────────────────────────────────────────
// 🔔 Pending new-reservations banner (visible to assistant only)
// ─────────────────────────────────────────────────────────────
class _PendingReservationsBanner extends StatelessWidget {
  const _PendingReservationsBanner();

  @override
  Widget build(BuildContext context) {
    final userType = Get.find<UserSession>().user?.user.userType;
    if (userType != UserType.assistant) return const SizedBox.shrink();

    if (!Get.isRegistered<NotificationController>()) {
      return const SizedBox.shrink();
    }

    return GetBuilder<NotificationController>(
      builder: (notifController) {
        final count = notifController.pendingReservationCount;
        if (count == 0) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            // Switch to notifications tab (index 1 for assistant)
            final mainVm = Get.find<MainPageViewModel>();
            mainVm.changeIndex(1);
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "$count",
                      style: context.typography.mdBold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    count == 1
                        ? "يوجد حجز جديد بانتظار موافقتك"
                        : "يوجد $count حجوزات جديدة بانتظار موافقتك",
                    style: context.typography.smMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
