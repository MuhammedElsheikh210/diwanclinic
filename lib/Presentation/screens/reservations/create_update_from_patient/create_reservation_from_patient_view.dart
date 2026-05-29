import 'package:diwanclinic/Presentation/screens/patients/search/patient_search_view.dart';
import '../../../../index/index_main.dart';

class CreateReservationFromPatientView extends StatefulWidget {
  final ReservationModel? reservation;
  final String? clinic_key;
  final String? shift_key;
  final int? total_reservations;
  final ClinicModel? selectedClinic;
  final LocalUser? selectedDoctor;

  const CreateReservationFromPatientView({
    Key? key,
    this.reservation,
    this.clinic_key,
    this.total_reservations,
    this.selectedClinic,
    this.shift_key,
    this.selectedDoctor,
  }) : super(key: key);

  @override
  State<CreateReservationFromPatientView> createState() =>
      _CreateReservationFromPatientViewState();
}

class _CreateReservationFromPatientViewState
    extends State<CreateReservationFromPatientView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();
  final GlobalKey<FormState> globalKeyReservation = GlobalKey<FormState>();
  late final CreateReservationFromPatientViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = initController(() => CreateReservationFromPatientViewModel());
    // call initData once
    vm.initData(
      reservation: widget.reservation,
      clinicKey: widget.clinic_key,
      shiftKey: widget.shift_key,
      totalReservations: widget.total_reservations,
      selectedClinic: widget.selectedClinic,
      doctor: widget.selectedDoctor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys(
      'CreateReservationFromPatientView',
      9,
    );

    return GetBuilder<CreateReservationFromPatientViewModel>(
      init: vm,
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.white,
          appBar: AppBar(
            elevation: 1,
            backgroundColor: AppColors.white,
            title: Text("إنشاء حجز جديد", style: context.typography.lgBold),
          ),
          bottomNavigationBar: SafeArea(
            child: SizedBox(
              height: 90.h,
              child: BottomNavigationActions(
                rightTitle: controller.is_update
                    ? "تحديث الحجز"
                    : "إضافة الحجز",
                rightAction: controller.saveReservation,
                isRightEnabled: controller.validateStep(),
              ),
            ),
          ),
          body: GetBuilder<CreateReservationViewModel>(
            init: CreateReservationViewModel(),
            builder: (controller) {
              return KeyboardActions(
                config: keyboardService.buildConfig(context, keys),
                child: Form(
                  key: globalKeyReservation,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      child: Column(
                        children: [
                          // نوع الحجز Dropdown
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15.0,
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
                              displayItemBuilder: (item) =>
                                  Text(item.name ?? ""),
                            ),
                          ),

                          // 💳 Online Payment Section
                          if (vm.doctorSupportsOnlinePay) ...[
                            SizedBox(height: 16.h),
                            _OnlinePaymentSection(controller: vm),
                          ],
                          SizedBox(height: 16.h),

                          // Row for Paid Amount & Rest Amount
                          if (controller.selectedType == "زيارة مندوب") ...[
                            CustomInputField(
                              label: "اسم المندوب",
                              controller: controller.delegateNameController,
                              hintText: "ادخل اسم المندوب",
                              focusNode: keyboardService.getFocusNode(keys[0]),
                              keyboardType: TextInputType.name,
                              voidCallbackAction: (value) {
                                controller.update();
                              },
                              validator: InputValidators.combine([
                                notEmptyValidator,
                              ]),
                            ),
                            SizedBox(height: 16.h),
                            CustomInputField(
                              label: "اسم الشركة",
                              controller: controller.companyNameController,
                              hintText: "ادخل اسم الشركة",
                              focusNode: keyboardService.getFocusNode(keys[1]),
                              keyboardType: TextInputType.text,
                              voidCallbackAction: (value) {
                                controller.update();
                              },
                              validator: InputValidators.combine([
                                notEmptyValidator,
                              ]),
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: CustomInputField(
                                    label: "المبلغ المدفوع",
                                    controller: controller.paidAmountController,
                                    hintText: "المبلغ المدفوع",
                                    keyboardType: TextInputType.number,
                                    voidCallbackAction: (value) {
                                      controller.update();
                                    },
                                    validator: InputValidators.combine([
                                      notEmptyValidator,
                                    ]),
                                    focusNode: keyboardService.getFocusNode(
                                      keys[4],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: CustomInputField(
                                    label: "المتبقي",
                                    controller: controller.restAmountController,
                                    hintText: "المبلغ المتبقي",
                                    keyboardType: TextInputType.number,
                                    voidCallbackAction: (value) {
                                      controller.update();
                                    },
                                    validator: InputValidators.combine([]),
                                    focusNode: keyboardService.getFocusNode(
                                      keys[5],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),

                            /// 🔹 Patient Search (Name)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: PatientSearchBar(
                                tag: "search_name",
                                hint: "اسم الحالة",
                                textEditingController:
                                    controller.patientNameController,
                                searchResult: (patientModel, name) {
                                  controller.clientUser = patientModel;
                                  controller.patient_name = name;
                                  if (patientModel != null) {
                                    controller.patientPhoneController.text =
                                        patientModel.phone ?? "";


                                  }
                                  controller.update();
                                },
                              ),
                            ),
                            SizedBox(height: 16.h),

                            /// 🔹 Patient Search (Phone)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: PatientSearchBar(
                                tag: "search_phone",
                                hint: "رقم الحالة",
                                textEditingController:
                                    controller.patientPhoneController,
                                searchResult: (patientModel, phone) {
                                  controller.clientUser = patientModel;
                                  controller.patientPhoneController.text =
                                      phone;
                                  if (patientModel != null) {
                                    controller.patientNameController.text =
                                        patientModel.name ?? "";

                                  }
                                  controller.update();
                                },
                              ),
                            ),
                            SizedBox(height: 16.h),

                            /// 🔹 Patient Search (Code)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: PatientSearchBar(
                                tag: "search_code",

                                hint: "كود الحالة",
                                textEditingController:
                                    controller.patientCodeController,
                                searchResult: (patientModel, code) {
                                  controller.clientUser = patientModel;
                                  controller.patientCodeController.text = code;
                                  if (patientModel != null) {
                                    controller.patientNameController.text =
                                        patientModel.name ?? "";
                                    controller.patientPhoneController.text =
                                        patientModel.phone ?? "";

                                  }
                                  controller.update();
                                },
                              ),
                            ),
                            SizedBox(height: 16.h),

                            /// 🔹 Address (يظل TextField عادي)
                            CustomInputField(
                              label: "العنوان",
                              controller: controller.patientCodeController,
                              hintText: "ادخل العنوان",
                              focusNode: keyboardService.getFocusNode(keys[2]),
                              keyboardType: TextInputType.text,
                              voidCallbackAction: (value) {
                                controller.update();
                              },
                              validator: InputValidators.combine([
                                notEmptyValidator,
                              ]),
                            ),
                            SizedBox(height: 16.h),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: CalenderWidget(
                                onDateSelected: (timeStamp, date) {
                                  controller.create_at =
                                      timeStamp.millisecondsSinceEpoch;
                                  controller.update();
                                },
                                initialTimestamp:
                                    controller.create_at ??
                                    DateTime.now().millisecondsSinceEpoch,
                                hintText: "تاريخ الحجز",
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _OnlinePaymentSection extends StatelessWidget {
  final CreateReservationFromPatientViewModel controller;

  const _OnlinePaymentSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final doctor = controller.selectedDoctor?.asDoctor;
    if (doctor == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background_neutral_100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "بيانات الدفع الإلكتروني",
                  style: context.typography.mdBold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),

                if (doctor.walletNumber != null &&
                    doctor.walletNumber!.isNotEmpty) ...[
                  _PaymentInfoRow(
                    icon: Icons.account_balance_wallet_outlined,
                    label: "رقم المحفظة",
                    value: doctor.walletNumber!,
                  ),
                  const SizedBox(height: 8),
                ],

                if (doctor.instapayNumber != null &&
                    doctor.instapayNumber!.isNotEmpty) ...[
                  _PaymentInfoRow(
                    icon: Icons.payment_outlined,
                    label: "رقم InstaPay",
                    value: doctor.instapayNumber!,
                  ),
                  const SizedBox(height: 8),
                ],

                if (doctor.instapayLink != null &&
                    doctor.instapayLink!.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.tryParse(doctor.instapayLink!);
                      if (uri != null && await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.link,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "افتح رابط InstaPay للدفع",
                            style: context.typography.mdMedium.copyWith(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.open_in_new,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // Payment method selector
          Text(
            "اختر طريقة الدفع",
            style: context.typography.mdBold,
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              if (doctor.walletNumber != null &&
                  doctor.walletNumber!.isNotEmpty)
                Expanded(
                  child: _PaymentMethodChip(
                    label: "محفظة",
                    icon: Icons.account_balance_wallet_outlined,
                    isSelected: controller.selectedPaymentMethod == 'wallet',
                    onTap: () => controller.selectPaymentMethod('wallet'),
                  ),
                ),
              if (doctor.walletNumber != null &&
                  doctor.walletNumber!.isNotEmpty &&
                  doctor.instapayNumber != null &&
                  doctor.instapayNumber!.isNotEmpty)
                const SizedBox(width: 10),
              if (doctor.instapayNumber != null &&
                  doctor.instapayNumber!.isNotEmpty)
                Expanded(
                  child: _PaymentMethodChip(
                    label: "InstaPay",
                    icon: Icons.payment_outlined,
                    isSelected: controller.selectedPaymentMethod == 'instapay',
                    onTap: () => controller.selectPaymentMethod('instapay'),
                  ),
                ),
            ],
          ),

          SizedBox(height: 14.h),

          // Screenshot upload
          Text(
            "ارفع صورة إثبات الدفع",
            style: context.typography.mdBold,
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: controller.pickPaymentScreenshot,
            child: Container(
              height: 120.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.paymentScreenshotFile != null
                      ? AppColors.primary
                      : AppColors.borderNeutralPrimary,
                  width: 1.5,
                ),
                color: AppColors.background_neutral_100,
              ),
              child: controller.paymentScreenshotFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.file(
                        controller.paymentScreenshotFile!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.upload_file,
                          color: AppColors.primary,
                          size: 32,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "اضغط لرفع صورة الدفع",
                          style: context.typography.mdMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PaymentInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondaryParagraph),
        const SizedBox(width: 6),
        Text(
          "$label: ",
          style: context.typography.smRegular.copyWith(
            color: AppColors.textSecondaryParagraph,
          ),
        ),
        Text(
          value,
          style: context.typography.mdBold,
        ),
      ],
    );
  }
}

class _PaymentMethodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.background_neutral_100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderNeutralPrimary,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondaryParagraph,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.typography.mdMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textDefault,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
