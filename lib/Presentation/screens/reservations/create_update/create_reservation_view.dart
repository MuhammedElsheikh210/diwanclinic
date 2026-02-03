import 'package:diwanclinic/Presentation/screens/patients/search/patient_search_view.dart';
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
    vm.resOrderController.text = widget.total_reservations.toString();
    vm.total_reservations = widget.total_reservations;
    vm.companyNameController.text = widget.dailly_date;
    vm.checkAndSyncClientsIfNeeded();
    final fixedDate = widget.dailly_date.replaceAll("/", "-");
    vm.loadLegacyQueueForDate(fixedDate);

    // Just trigger loading clinic and reservation count

    // تاريخ النهارده
    final today = DateTime.now();
    vm.create_at = today.millisecondsSinceEpoch;

    vm.companyNameController.text = DateFormat('dd/MM/yyyy').format(today);

    // حمّل الكشكول + احسب رقم الحجز
    vm.onDateChanged(today);

    vm.getClinicList(
      widget.selected_clinic,
      widget.reservation ?? ReservationModel(),
    );
    if (widget.reservation != null) {
      vm.existingReservation = widget.reservation;

      vm.is_update = true;
    }

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

          // ✅ Fixed bottom button

          // ✅ Scrollable form body
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
                        /// 🔹 البحث برقم الهاتف
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: PatientSearchBar(
                            tag: "search_phone",
                            hint: "ابحث برقم الهاتف",
                            textInputType: TextInputType.phone,
                            focusNode: keyboardService.getFocusNode(keys[0]),
                            textEditingController:
                                controller.patientPhoneController,
                            searchResult: (patientModel, text) {
                              setState(() {
                                // ✅ Show phone list only when typing and name list is hidden
                                showPhoneList =
                                    text.isNotEmpty && !showNameList;
                                if (text.isEmpty) showPhoneList = false;
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
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: PatientSearchBar(
                            tag: "search_name",
                            hint: "ابحث بالاسم",
                            focusNode: keyboardService.getFocusNode(keys[1]),
                            textEditingController:
                                controller.patientNameController,
                            searchResult: (patientModel, text) {
                              setState(() {
                                showNameList =
                                    text.isNotEmpty && !showPhoneList;
                                if (text.isEmpty) showNameList = false;
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

                        // Padding(
                        //   padding: EdgeInsets.only(
                        //     left: 15.0.w,
                        //     right: 15,
                        //     top: 15.h,
                        //   ),
                        //   child: PatientSearchBar(
                        //     tag: "search_code",
                        //     hint: "ابحث برقم الملف",
                        //     textInputType: TextInputType.number,
                        //     focusNode: keyboardService.getFocusNode(keys[2]),
                        //     textEditingController:
                        //         controller.patientCodeController,
                        //     searchResult: (patientModel, text) {
                        //       setState(() {
                        //         showCodeList = text.isNotEmpty;
                        //       });
                        //     },
                        //     onCloseList: () {
                        //       setState(() => showCodeList = false);
                        //       FocusScope.of(context).unfocus();
                        //     },
                        //   ),
                        // ),
                        if (showCodeList)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15.0,
                            ),
                            child: PatientResultList(
                              tag: "search_code",
                              onSelect: (client) {
                                _fillPatientData(controller, client);
                                setState(() => showCodeList = false);
                              },
                            ),
                          ),

                        if (controller.lastReservationHumanText != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 15.0,
                              right: 15,
                              top: 8,
                            ),
                            child: Text(
                              "آخر كشف: ${controller.lastReservationHumanText}",
                              style: context.typography.mdRegular.copyWith(
                                color: AppColors.errorForeground,
                              ),
                            ),
                          ),

                        // /// 🔹 رقم الملف
                        // controller.selectedClinic?.file_number == 0
                        //     ? const SizedBox()
                        //     : Padding(
                        //         padding: EdgeInsets.only(
                        //           left: 15.0.w,
                        //           right: 15,
                        //           top: 15.h,
                        //         ),
                        //         child: AppTextField(
                        //           controller: controller.patientCodeController,
                        //           hintText: "رقم الملف",
                        //           focusNode: keyboardService.getFocusNode(
                        //             keys[2],
                        //           ),
                        //           keyboardType: TextInputType.text,
                        //           validator: InputValidators.combine([
                        //             notEmptyValidator,
                        //           ]),
                        //         ),
                        //       ),

                        /// 🔹 نوع الحجز
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15.0,
                            vertical: 15,
                          ),
                          child: GenericDropdown<GenericListModel>(
                            hint_text: "نوع الحجز",
                            title: "اختر نوع الحجز",
                            items: controller.typeOptions
                                .map((e) => GenericListModel(name: e))
                                .toList(),
                            initialValue: controller.selectedType != null
                                ? GenericListModel(
                                    name: controller.selectedType!,
                                  )
                                : null,
                            onChanged: (val) {
                              controller.setReservationType(val.name);
                              controller.selectedType = val.name;
                              controller.update();
                            },

                            displayItemBuilder: (item) => Text(item.name ?? ""),
                          ),
                        ),

                        /// 🔹 المبالغ
                        controller.selectedType == "متابعة"
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: AppTextField(
                                        controller:
                                            controller.paidAmountController,
                                        hintText: "المدفوع",
                                        keyboardType: TextInputType.number,
                                        validator: InputValidators.combine([
                                          notEmptyValidator,
                                        ]),
                                        focusNode: keyboardService.getFocusNode(
                                          keys[4],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: AppTextField(
                                        controller:
                                            controller.restAmountController,
                                        hintText: "المتبقي",
                                        keyboardType: TextInputType.number,
                                        focusNode: keyboardService.getFocusNode(
                                          keys[5],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),

                                    controller.selectedType == "متابعة"
                                        ? const SizedBox()
                                        : Expanded(
                                            child: AppTextField(
                                              hintText: "رقم الكشف",
                                              enabled:
                                                  controller.isFromLegacyQueue,
                                              controller:
                                                  controller.resOrderController,
                                              keyboardType:
                                                  TextInputType.number,
                                              focusNode: keyboardService
                                                  .getFocusNode(keys[6]),
                                            ),
                                          ),
                                  ],
                                ),
                              ),

                        Padding(
                          padding: const EdgeInsets.only(
                            left: 15.0,
                            right: 15,
                            top: 15,
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
                                'dd/MM/yyyy',
                              ).format(pickedDate);

                              if (formatted !=
                                  controller.companyNameController.text) {
                                controller.companyNameController.text =
                                    formatted;

                                // 1️⃣ حمّل الكشكول
                                await controller.loadLegacyQueueForDate(
                                  DateFormat('dd-MM-yyyy').format(pickedDate),
                                );

                                // 2️⃣ 🔥 احسب عدد الحجوزات لليوم الجديد
                                controller.total_reservations = await controller
                                    .getTotalTodayReservations(formatted);

                                // 3️⃣ 🔥 احسب رقم الحجز
                                controller.recalculateOrderNum();
                              }

                              controller.update();
                            },
                          ),
                        ),

                        /// 🗂️ Legacy Queue Checkbox (Assistant only)
                        if (LocalUser().getUserData().userType?.name ==
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
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.borderNeutralPrimary
                                      .withOpacity(0.6),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: controller.isFromLegacyQueue,
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
                                      style: context.typography.mdMedium
                                          .copyWith(
                                            color: AppColors.textDisplay,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        SizedBox(height: 16.h),

                        // /// 🔹 التقويم
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        //   child: CalenderWidget(
                        //     onDateSelected: (timeStamp, date) {
                        //       controller.create_at =
                        //           timeStamp.millisecondsSinceEpoch;
                        //
                        //       final formatted = DateFormat('yyyy-MM-dd').format(
                        //         DateTime.fromMillisecondsSinceEpoch(
                        //           timeStamp.millisecondsSinceEpoch,
                        //         ),
                        //       );
                        //
                        //       final total =
                        //           controller.clinicModel
                        //               ?.getTotalReservationsForDate(
                        //                 formatted,
                        //               ) ??
                        //           0;
                        //       final urgent =
                        //           controller.clinicModel
                        //               ?.getUrgentReservationsForDate(
                        //                 formatted,
                        //               ) ??
                        //           0;
                        //
                        //       int nextOrder;
                        //       if (controller.selectedType == "كشف مستعجل") {
                        //         nextOrder = (urgent + 1).toInt();
                        //       } else {
                        //         nextOrder = (total + urgent + 1).toInt();
                        //       }
                        //
                        //       controller.resOrderController.text = nextOrder
                        //           .toString();
                        //
                        //       debugPrint(
                        //         "📅 [$formatted] type=${controller.selectedType} → total=$total | urgent=$urgent → next=$nextOrder",
                        //       );
                        //       controller.update();
                        //     },
                        //
                        //     initialTimestamp:
                        //         controller.create_at ??
                        //         DateTime.now().millisecondsSinceEpoch,
                        //     hintText: "تاريخ الحجز",
                        //   ),
                        // ),
                        SizedBox(height: 50.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                          child: SizedBox(
                            width: ScreenUtil().screenWidth,
                            height: 55.h,
                            child: PrimaryTextButton(
                              appButtonSize: AppButtonSize.xxLarge,
                              onTap: controller.validateStep()
                                  ? () {
                                      controller.saveReservation(
                                        widget.list_reservations,
                                        widget.selected_clinic,
                                      );
                                    }
                                  : null,
                              label: AppText(
                                text: controller.is_update
                                    ? "تحديث الحجز"
                                    : "إضافة الحجز",
                                textStyle: context.typography.mdMedium.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
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
