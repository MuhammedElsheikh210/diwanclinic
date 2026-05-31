import 'package:diwanclinic/Presentation/screens/patients/profile_history_all_reservations/medical_record_form/embedded_medical_record_form.dart';
import '../../../../index/index_main.dart';

class PatientAllHistoryView extends StatefulWidget {
  final String patientKey;
  const PatientAllHistoryView({super.key, required this.patientKey});

  @override
  State<PatientAllHistoryView> createState() => _PatientAllHistoryViewState();
}

class _PatientAllHistoryViewState extends State<PatientAllHistoryView> {
  late final PatientProfileAllHistoryViewModel controller;
  int selectedTab = 0;

  @override
  void initState() {
    controller = initController(() => PatientProfileAllHistoryViewModel());
    controller.getData(widget.patientKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatientProfileAllHistoryViewModel>(
      init: controller,
      builder: (vm) {
        return Scaffold(
          backgroundColor: AppColors.background_neutral_100,
          bottomNavigationBar: vm.canCompleteCurrentReservation
              ? _CompleteButton(vm: vm)
              : null,
          body: vm.reservations.isEmpty
              ? const _LoadingBody()
              : KeyboardActions(
                  config: vm.keyboardService.buildConfig(
                    context,
                    vm.keyboardKeys,
                  ),
                  child: CustomScrollView(
                    slivers: [
                      _PatientSliverAppBar(patient: vm.patientModel),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                16.w, 16.h, 16.w, 0,
                              ),
                              child: _TabSwitcher(
                                selectedTab: selectedTab,
                                onTabChange: (i) =>
                                    setState(() => selectedTab = i),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                16.w, 14.h, 16.w, 30.h,
                              ),
                              child: selectedTab == 0
                                  ? EmbeddedMedicalRecordForm(vm: vm)
                                  : _HistoryList(vm: vm),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

// ── Loading ───────────────────────────────────────────────────
class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

// ── Sliver app bar with patient hero ─────────────────────────
class _PatientSliverAppBar extends StatelessWidget {
  final LocalUser? patient;
  const _PatientSliverAppBar({required this.patient});

  String get _initials {
    final name = (patient?.name ?? '').trim();
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0];
    return '${parts[0][0]}${parts[1][0]}';
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160.h,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: EdgeInsets.all(10.r),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B8354), Color(0xFF22A06B)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 14.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _initials,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    patient?.name ?? '-',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  if ((patient?.phone ?? '').isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: 12.sp,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          patient?.phone ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated tab switcher ─────────────────────────────────────
class _TabSwitcher extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChange;

  const _TabSwitcher({
    required this.selectedTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.dividerAndLines),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final tabWidth = (constraints.maxWidth - 8.w) / 2;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                right: selectedTab == 0 ? 0 : tabWidth,
                top: 0,
                child: Container(
                  width: tabWidth,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(11.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _TabBtn(
                      label: 'الكشف الحالي',
                      isSelected: selectedTab == 0,
                      onTap: () => onTabChange(0),
                    ),
                  ),
                  Expanded(
                    child: _TabBtn(
                      label: 'سجل الكشوفات',
                      isSelected: selectedTab == 1,
                      onTap: () => onTabChange(1),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabBtn({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 44.h,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: isSelected ? 14.sp : 13.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondaryParagraph,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

// ── History list ──────────────────────────────────────────────
class _HistoryList extends StatelessWidget {
  final PatientProfileAllHistoryViewModel vm;
  const _HistoryList({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: vm.reservations.asMap().entries.map((entry) {
        final reservation = entry.value;
        return ReservationHistoryCard(
          reservation: reservation,
          medicalRecord: vm.getMedicalRecordByReservationKey(reservation.key),
          isInitiallyExpanded: entry.key == 0,
        );
      }).toList(),
    );
  }
}

// ── Complete exam button ──────────────────────────────────────
class _CompleteButton extends StatelessWidget {
  final PatientProfileAllHistoryViewModel vm;
  const _CompleteButton({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: GestureDetector(
            onTap: () async {
              final reservation = vm.currentReservation;
              if (reservation == null) return;
              await vm.completeReservation(reservation: reservation);
            },
            child: Container(
              width: double.infinity,
              height: 54.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B8354), Color(0xFF22A06B)],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'تم الكشف',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
