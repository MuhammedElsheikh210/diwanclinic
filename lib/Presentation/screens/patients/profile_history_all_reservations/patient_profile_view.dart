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

  final HandleKeyboardService keyboardService = HandleKeyboardService();

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
        final patient = vm.patientModel;

        return Scaffold(
          backgroundColor: AppColors.background_neutral_100,

          appBar: PreferredSize(
            preferredSize: Size.fromHeight(75.h),

            child: AppBar(
              automaticallyImplyLeading: false,

              elevation: 0,

              backgroundColor: AppColors.white,

              surfaceTintColor: AppColors.white,

              flexibleSpace: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),

                  child: Row(
                    children: [
                      /// Back Button
                      InkWell(
                        borderRadius: BorderRadius.circular(16.r),

                        onTap: () => Get.back(),

                        child: Container(
                          width: 48.w,
                          height: 48.h,

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),

                            color: AppColors.background_neutral_100,
                          ),

                          child: Icon(
                            Icons.arrow_back_ios,

                            size: 18.sp,

                            color: AppColors.background_black,
                          ),
                        ),
                      ),

                      SizedBox(width: 14.w),

                      /// Avatar
                      Container(
                        width: 58.w,
                        height: 58.h,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.15),

                              AppColors.primary.withValues(alpha: 0.05),
                            ],

                            begin: Alignment.topLeft,

                            end: Alignment.bottomRight,
                          ),
                        ),

                        child: Icon(
                          Icons.person_rounded,

                          color: AppColors.primary,

                          size: 30.sp,
                        ),
                      ),

                      SizedBox(width: 14.w),

                      /// Patient Info
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              patient?.name ?? "-",

                              maxLines: 1,

                              overflow: TextOverflow.ellipsis,

                              style: context.typography.xlBold.copyWith(
                                color: AppColors.background_black,
                              ),
                            ),

                            SizedBox(height: 4.h),

                            Row(
                              children: [
                                Icon(
                                  Icons.phone_rounded,

                                  size: 15.sp,

                                  color: AppColors.textSecondaryParagraph,
                                ),

                                SizedBox(width: 5.w),

                                Text(
                                  patient?.phone ?? "-",

                                  style: context.typography.smMedium.copyWith(
                                    color: AppColors.textSecondaryParagraph,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),

                child: Container(
                  height: 1,

                  color: AppColors.borderNeutralPrimary.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          bottomNavigationBar:
              vm.canCompleteCurrentReservation
                  ? Container(
                    decoration: const BoxDecoration(color: AppColors.primary),

                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),

                        child: PrimaryTextButton(
                          onTap: () async {
                            final reservation = vm.currentReservation;

                            if (reservation == null) {
                              return;
                            }

                            await vm.completeReservation(
                              reservation: reservation,
                            );
                          },

                          appButtonSize: AppButtonSize.xxLarge,

                          customBackgroundColor: AppColors.primary,

                          elevation: 0,

                          label: AppText(
                            text: "تم الكشف",

                            textStyle: context.typography.lgBold.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  : null,
          body: KeyboardActions(
            config: vm.keyboardService.buildConfig(context, vm.keyboardKeys),
            child:
                vm.reservations.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(

                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 20),

                      children: [
                        /// Tabs
                        _buildTabs(),
                        SizedBox(height: 20.h),

                        /// Current Visit
                        if (selectedTab == 0) EmbeddedMedicalRecordForm(vm: vm),

                        /// History
                        if (selectedTab == 1) _buildHistory(vm),
                      ],
                    ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // Tabs
  // ------------------------------------------------------------
  Widget _buildTabs() {
    return Container(
      height: 58.h,

      padding: EdgeInsets.all(4.r),

      decoration: BoxDecoration(
        color: AppColors.background_neutral_100,

        borderRadius: BorderRadius.circular(14.r),

        border: Border.all(color: AppColors.borderNeutralPrimary),
      ),

      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 8.w) / 2;

          return Stack(
            children: [
              /// Animated Background
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),

                curve: Curves.easeInOutCubic,

                right: selectedTab == 0 ? 0 : tabWidth,

                top: 0,

                child: Container(
                  width: tabWidth,

                  height: 50.h,

                  decoration: BoxDecoration(
                    color: AppColors.white,

                    borderRadius: BorderRadius.circular(12.r),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),

                        blurRadius: 10,

                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              /// Tabs
              Row(
                children: [
                  Expanded(
                    child: _AnimatedTabItem(
                      label: "الكشف الحالي",

                      isSelected: selectedTab == 0,

                      onTap: () {
                        setState(() {
                          selectedTab = 0;
                        });
                      },
                    ),
                  ),

                  Expanded(
                    child: _AnimatedTabItem(
                      label: "سجل الكشوفات",

                      isSelected: selectedTab == 1,

                      onTap: () {
                        setState(() {
                          selectedTab = 1;
                        });
                      },
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

  // ------------------------------------------------------------
  // History
  // ------------------------------------------------------------
  Widget _buildHistory(PatientProfileAllHistoryViewModel vm) {
    return Column(
      children: [
        ...vm.reservations.asMap().entries.map((entry) {
          final index = entry.key;

          final reservation = entry.value;

          return ReservationHistoryCard(
            reservation: reservation,

            medicalRecord: vm.getMedicalRecordByReservationKey(reservation.key),

            isInitiallyExpanded: index == 0,
          );
        }),
      ],
    );
  }
}

class _AnimatedTabItem extends StatelessWidget {
  final String label;

  final bool isSelected;

  final VoidCallback onTap;

  const _AnimatedTabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),

      onTap: onTap,

      child: SizedBox(
        height: 50.h,

        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),

            curve: Curves.easeInOut,

            style: context.typography.mdBold.copyWith(
              color:
                  isSelected
                      ? AppColors.primary
                      : AppColors.textSecondaryParagraph,

              fontSize: isSelected ? 15.sp : 14.sp,
            ),

            child: Text(label),
          ),
        ),
      ),
    );
  }
}
