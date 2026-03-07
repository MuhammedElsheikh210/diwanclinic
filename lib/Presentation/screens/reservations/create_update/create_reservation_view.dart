import 'package:diwanclinic/Presentation/screens/patients/search/patient_search_view.dart';
import 'package:diwanclinic/Presentation/screens/reservations/create_update/horizontal_steppers_widget.dart';
import 'package:diwanclinic/Presentation/screens/reservations/create_update/reservation_bottom_navigation.dart';
import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class CreateReservationView extends StatefulWidget {
  final ReservationModel? reservation;
  final String? clinic_key;
  final String dailly_date;
  final ClinicModel selected_clinic;
  final String? shift_key;
  final int total_reservations;
  final List<ReservationModel?> list_reservations;
  final int? need_deposite;

  const CreateReservationView({
    Key? key,
    this.reservation,
    this.clinic_key,
    this.need_deposite,
    required this.total_reservations,
    required this.list_reservations,
    required this.dailly_date,
    required this.selected_clinic,
    this.shift_key,
  }) : super(key: key);

  @override
  State<CreateReservationView> createState() => _CreateReservationViewState();
}

class _CreateReservationViewState extends State<CreateReservationView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();
  final GlobalKey<FormState> globalKeyReservation = GlobalKey<FormState>();

  bool showNameList = false;
  bool showPhoneList = false;
  bool showCodeList = false;

  final FocusNode phoneFocus = FocusNode();
  final FocusNode nameFocus = FocusNode();
  final FocusNode codeFocus = FocusNode();
  final vm = initController(() => CreateReservationViewModel());

  @override
  void initState() {
    super.initState();

    vm.clinic_key = widget.clinic_key;
    vm.shift_key = widget.shift_key;
    vm.loadShiftsForClinic();
    final totalReservation = widget.total_reservations + 1;
    vm.resOrderController.text = totalReservation.toString();
    vm.total_reservations = totalReservation;

    final today = DateTime.now();
    DateTime selectedDate = today;

    // ================================
    // 🔵 UPDATE MODE
    // ================================
    if (widget.reservation != null &&
        widget.reservation!.appointmentDateTime != null &&
        widget.reservation!.appointmentDateTime!.isNotEmpty) {
      try {
        selectedDate = DateFormat(
          'dd-MM-yyyy',
        ).parse(widget.reservation!.appointmentDateTime!);
      } catch (_) {
        selectedDate = today;
      }

      vm.existingReservation = widget.reservation;
      vm.is_update = true;
    }
    // ================================
    // 🟢 CREATE MODE
    // ================================
    else {
      selectedDate = today;
    }

    // 🔹 اضبط التاريخ في الـ ViewModel
    vm.create_at = selectedDate.millisecondsSinceEpoch;
    vm.companyNameController.text = DateFormat(
      'dd-MM-yyyy',
    ).format(selectedDate);

    // 🔹 حمّل حالة اليوم (مفتوح / مغلق)
    vm.loadOpenCloseStatusForDate(
      DateFormat('dd-MM-yyyy').format(selectedDate),
    );

    // 🔹 حمّل حالة اليوم (مفتوح / مغلق)
    vm.loadLegacyQueueForDate(DateFormat('dd-MM-yyyy').format(selectedDate));

    // 🔹 حمّل بيانات العيادة + المريض
    vm.getClinicList(
      widget.selected_clinic,
      widget.reservation ?? ReservationModel(),
    );

    vm.update();
  }

  String formatLegacyDate(DateTime date) {
    return DateFormat("dd-MM-yyyy").format(date);
  }

  @override
  void dispose() {
    phoneFocus.dispose();
    nameFocus.dispose();
    codeFocus.dispose();
    super.dispose();
  }

  void _fillPatientData(
    CreateReservationViewModel controller,
    LocalUser client,
  ) {
    controller.getLastReservationDateHuman(client);
    controller.clientUser = client;
    controller.patientNameController.text = client.name ?? "";
    controller.patientPhoneController.text = client.phone ?? "";
    controller.patientCodeController.text = client.code ?? "";
    controller.update();

    setState(() {
      showNameList = false;
      showPhoneList = false;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('CreateReservationView', 9);

    return GetBuilder<CreateReservationViewModel>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            elevation: 1,
            backgroundColor: AppColors.white,
            title: Text("إنشاء حجز جديد", style: context.typography.lgBold),
          ),

          bottomNavigationBar: SafeArea(
            child: SizedBox(
              height: 150.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),

                  if (controller.isDayClosed)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      child: Text(
                        "هذا اليوم مُغلق بقرار الإدارة",
                        style: context.typography.lgBold.copyWith(
                          color: AppColors.errorForeground,
                        ),
                      ),
                    ),

                  ReservationBottomNavigation(
                    controller: controller,
                    onSave: () {
                      // 🚫 اليوم مغلق
                      if (controller.isDayClosed) {
                        Loader.showError("🚫 اليوم مغلق للحجوزات");
                        return;
                      }

                      // ❌ Validation فشل
                      if (!controller.validateCurrentStep()) {
                        Loader.showError("⚠️ اكمل بيانات الخطوة الحالية");
                        return;
                      }

                      // ✅ لو آخر خطوة → احفظ
                      if (controller.currentStep == 3) {
                        controller.saveReservation(
                          widget.list_reservations,
                          widget.selected_clinic,
                        );
                      } else {
                        controller.nextStep();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          body: KeyboardActions(
            config: keyboardService.buildConfig(context, keys),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: globalKeyReservation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Horizontal Stepper
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: HorizontalStepper(
                            currentStep: controller.currentStep - 1,
                            titles: const ["الدور", "المريض", "الدفع"],
                            subtitles: const [
                              "تاريخ ورقم الحجز",
                              "بيانات المريض",
                              "نوع الحجز والمبلغ",
                            ],
                          ),
                        ),

                        controller.currentStep != 2
                            ? const SizedBox()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// 🔹 البحث برقم الهاتف
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                    ),
                                    child: PatientSearchBar(
                                      tag: "search_phone",
                                      hint: "ابحث برقم الهاتف",
                                      textInputType: TextInputType.phone,
                                      focusNode: keyboardService.getFocusNode(
                                        keys[0],
                                      ),
                                      textEditingController:
                                          controller.patientPhoneController,
                                      searchResult: (patientModel, text) {
                                        setState(() {
                                          // ✅ Show phone list only when typing and name list is hidden
                                          showPhoneList =
                                              text.isNotEmpty && !showNameList;
                                          if (text.isEmpty)
                                            showPhoneList = false;
                                        });
                                      },
                                      onCloseList: () {
                                        // ✅ Just hide the list, keep the text intact
                                        setState(() {
                                          showPhoneList = false;
                                        });
                                        FocusScope.of(
                                          context,
                                        ).unfocus(); // optional, hides keyboard
                                      },
                                    ),
                                  ),

                                  if (showPhoneList)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0,
                                      ),
                                      child: PatientResultList(
                                        tag: "search_phone",
                                        onSelect: (client) {
                                          _fillPatientData(controller, client);
                                          setState(() {
                                            showPhoneList =
                                                false; // ✅ Hide results when a patient is selected
                                          });
                                        },
                                      ),
                                    ),

                                  SizedBox(height: 20.h),

                                  /// 🔹 البحث بالاسم
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                    ),
                                    child: PatientSearchBar(
                                      tag: "search_name",
                                      hint: "ابحث بالاسم",
                                      focusNode: keyboardService.getFocusNode(
                                        keys[1],
                                      ),
                                      textEditingController:
                                          controller.patientNameController,
                                      searchResult: (patientModel, text) {
                                        setState(() {
                                          showNameList =
                                              text.isNotEmpty && !showPhoneList;
                                          if (text.isEmpty)
                                            showNameList = false;
                                        });
                                      },
                                      onCloseList: () {
                                        setState(() {
                                          showNameList =
                                              false; // ✅ Only hides results, doesn’t clear text
                                        });
                                      },
                                    ),
                                  ),

                                  if (showNameList)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0,
                                      ),
                                      child: PatientResultList(
                                        tag: "search_name",
                                        onSelect: (client) {
                                          _fillPatientData(controller, client);
                                          setState(() => showNameList = false);
                                        },
                                      ),
                                    ),

                                  if (controller.lastReservationHumanText !=
                                      null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 15.0,
                                        right: 15,
                                        top: 8,
                                      ),
                                      child: Text(
                                        "آخر كشف: ${controller.lastReservationHumanText}",
                                        style: context.typography.mdRegular
                                            .copyWith(
                                              color: AppColors.errorForeground,
                                            ),
                                      ),
                                    ),
                                ],
                              ),

                        /// 🔹 نوع الحجز
                        controller.currentStep != 3
                            ? const SizedBox()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "نوع الحجز",
                                          style: context.typography.mdMedium,
                                        ),
                                        const SizedBox(height: 12),

                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          children: controller.typeOptions.map((
                                            type,
                                          ) {
                                            final isSelected =
                                                controller.selectedType == type;

                                            return GestureDetector(
                                              onTap: () {
                                                controller.setReservationType(
                                                  type,
                                                );
                                                controller.selectedType = type;
                                                controller.update();
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 18,
                                                      vertical: 14,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppColors.primary
                                                            .withOpacity(0.1)
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? AppColors.primary
                                                        : Colors.grey.shade300,
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: isSelected
                                                      ? [
                                                          BoxShadow(
                                                            color: AppColors
                                                                .primary
                                                                .withOpacity(
                                                                  0.15,
                                                                ),
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  3,
                                                                ),
                                                          ),
                                                        ]
                                                      : [],
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle,
                                                      size: 18,
                                                      color: isSelected
                                                          ? AppColors.primary
                                                          : Colors.transparent,
                                                    ),
                                                    if (isSelected)
                                                      const SizedBox(width: 6),
                                                    Text(
                                                      type,
                                                      style: context
                                                          .typography
                                                          .mdMedium
                                                          .copyWith(
                                                            color: isSelected
                                                                ? AppColors
                                                                      .primary
                                                                : Colors
                                                                      .grey
                                                                      .shade700,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// 🔹 المبالغ
                                  controller.selectedType == "متابعة"
                                      ? const SizedBox()
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0,
                                            vertical: 30,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: AppTextField(
                                                  controller: controller
                                                      .paidAmountController,
                                                  hintText: "المدفوع",
                                                  keyboardType:
                                                      TextInputType.number,
                                                  validator:
                                                      InputValidators.combine([
                                                        notEmptyValidator,
                                                      ]),
                                                  focusNode: keyboardService
                                                      .getFocusNode(keys[4]),
                                                ),
                                              ),
                                              SizedBox(width: 10.w),
                                              Expanded(
                                                child: AppTextField(
                                                  controller: controller
                                                      .restAmountController,
                                                  hintText: "المتبقي",
                                                  keyboardType:
                                                      TextInputType.number,
                                                  focusNode: keyboardService
                                                      .getFocusNode(keys[5]),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),

                        controller.currentStep != 1
                            ? const SizedBox()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // controller.selectedType == "متابعة"
                                  //     ? const SizedBox()
                                  //     :
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                    ),
                                    child: Text(
                                      "رقم الدور ",
                                      style: context.typography.lgBold.copyWith(
                                        color: AppColors.background_black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 7),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                    ),
                                    child: AppTextField(
                                      hintText: "رقم الكشف",
                                      enabled: controller.isFromLegacyQueue,
                                      controller: controller.resOrderController,
                                      keyboardType: TextInputType.number,
                                      focusNode: keyboardService.getFocusNode(
                                        keys[6],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                    ),
                                    child: Text(
                                      "تاريخ الكشف ",
                                      style: context.typography.lgBold.copyWith(
                                        color: AppColors.background_black,
                                      ),
                                    ),
                                  ),
                                  // رقم الكشف
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 15.0,
                                      right: 15,

                                      top: 8,
                                    ),
                                    child: CalenderWidget(
                                      hintText: "تاريخ الحجز",
                                      initialTimestamp:
                                          controller.create_at ??
                                          DateTime.now().millisecondsSinceEpoch,
                                      onDateSelected: (timeStamp, date) async {
                                        final pickedDate =
                                            DateTime.fromMillisecondsSinceEpoch(
                                              timeStamp.millisecondsSinceEpoch,
                                            );

                                        controller.create_at =
                                            timeStamp.millisecondsSinceEpoch;

                                        final formatted = DateFormat(
                                          'dd-MM-yyyy',
                                        ).format(pickedDate);

                                        if (formatted !=
                                            controller
                                                .companyNameController
                                                .text) {
                                          controller
                                                  .companyNameController
                                                  .text =
                                              formatted;
                                          final formattedLegacyDate =
                                              DateFormat(
                                                'dd-MM-yyyy',
                                              ).format(pickedDate);
                                          // 1️⃣ حمّل الكشكول
                                          await controller
                                              .loadLegacyQueueForDate(
                                                DateFormat(
                                                  'dd-MM-yyyy',
                                                ).format(pickedDate),
                                              );

                                          // 🔥 حالة اليوم (open / close)
                                          await controller
                                              .loadOpenCloseStatusForDate(
                                                formattedLegacyDate,
                                              );

                                          // 2️⃣ 🔥 احسب عدد الحجوزات لليوم الجديد
                                          controller.total_reservations =
                                              await controller
                                                  .getTotalTodayReservations(
                                                    formatted,
                                                  );

                                          // 3️⃣ 🔥 احسب رقم الحجز
                                          controller.recalculateOrderNum();
                                        }

                                        controller.update();
                                      },
                                    ),
                                  ),

                                  if (controller.shiftItems.length > 1)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 20,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "الفترة",
                                            style: context.typography.mdMedium,
                                          ),
                                          const SizedBox(height: 8),

                                          if (controller.isLoadingShifts)
                                            const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          else
                                            Wrap(
                                              spacing: 12,
                                              runSpacing: 12,
                                              children: controller.shiftItems.map((
                                                shift,
                                              ) {
                                                final isSelected =
                                                    controller
                                                        .selectedShiftModel
                                                        ?.key ==
                                                    shift.key;

                                                return GestureDetector(
                                                  onTap: () => controller
                                                      .selectShift(shift),
                                                  child: AnimatedContainer(
                                                    duration: const Duration(
                                                      milliseconds: 200,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 18,
                                                          vertical: 14,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? AppColors.primary
                                                                .withValues(
                                                                  alpha: 0.1,
                                                                )
                                                          : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                      border: Border.all(
                                                        color: isSelected
                                                            ? AppColors.primary
                                                            : Colors
                                                                  .grey
                                                                  .shade300,
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      shift.name ?? "",
                                                      style: context
                                                          .typography
                                                          .mdMedium
                                                          .copyWith(
                                                            color: isSelected
                                                                ? AppColors
                                                                      .primary
                                                                : Colors
                                                                      .grey
                                                                      .shade700,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                        ],
                                      ),
                                    ),

                                  /// 🗂️ Legacy Queue Checkbox (Assistant only)
                                  if (LocalUser()
                                              .getUserData()
                                              .userType
                                              ?.name ==
                                          Strings.assistant &&
                                      controller.legacyQueueCount > 0)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0,
                                        vertical: 15,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 10.h,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors
                                                .borderNeutralPrimary
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value:
                                                  controller.isFromLegacyQueue,
                                              activeColor: AppColors.primary,
                                              onChanged: (val) {
                                                controller.toggleLegacyQueue(
                                                  val ?? false,
                                                );
                                              },
                                            ),
                                            Expanded(
                                              child: Text(
                                                "الحجز ده مسجّل في الكشكول",
                                                style: context
                                                    .typography
                                                    .mdMedium
                                                    .copyWith(
                                                      color:
                                                          AppColors.textDisplay,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  SizedBox(height: 16.h),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
