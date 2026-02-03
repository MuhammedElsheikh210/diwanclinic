import 'package:diwanclinic/Presentation/screens/patients/search/patient_search_view.dart';
import 'package:diwanclinic/Presentation/screens/reservations/create_update_from_patient/create_reservation_from_patient_view_model.dart';
import '../../../../index/index_main.dart';

class CreateReservationFromPatientView extends StatefulWidget {
  final ReservationModel? reservation;
  final String? clinic_key;
  final String? shift_key;
  final int? total_reservations;
  final ClinicModel? selectedClinic;

  const CreateReservationFromPatientView({
    Key? key,
    this.reservation,
    this.clinic_key,
    this.total_reservations,
    this.selectedClinic,
    this.shift_key,
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
                                    controller.patientCodeController.text =
                                        patientModel.code ?? "";

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
                                    controller.patientCodeController.text =
                                        patientModel.code ?? "";

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
