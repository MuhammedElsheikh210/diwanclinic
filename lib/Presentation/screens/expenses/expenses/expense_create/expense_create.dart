// Updated CreateExpenseView with functional CreateExpenseViewModel integration
// and Wallet selection logic.

import 'package:diwanclinic/Presentation/screens/expenses/expenses/status.dart';

import '../../../../../index/index_main.dart';

class CreateExpenseView extends StatefulWidget {
  final TransactionsEntity? expenseEntity;

  const CreateExpenseView({Key? key, this.expenseEntity}) : super(key: key);

  @override
  State<CreateExpenseView> createState() => _CreateExpenseViewState();
}

class _CreateExpenseViewState extends State<CreateExpenseView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();
  final GlobalKey<FormState> globalKeyExpense = GlobalKey<FormState>();
  DateTime? selectedDate;
  late final CreateExpenseViewModel createExpenseVM = initController(
    () => CreateExpenseViewModel(),
  );

  @override
  void initState() {
    super.initState();
    // Initialize the ViewModel and pass the merchant/curior if provided.
    createExpenseVM.existingExpense = widget.expenseEntity;
    // createExpenseVM.getWalletData();
    // createExpenseVM.getCategoryList();
    // // to update
    // if (widget.expenseEntity != null) {
    //   createExpenseVM.existingExpense = widget.expenseEntity;
    //   createExpenseVM.isUpdate =
    //       createExpenseVM.existingExpense != null ? true : false;
    //   createExpenseVM.populateFields(
    //     widget.expenseEntity ?? TransactionsEntity(),
    //   );
    // }
    createExpenseVM.update();
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('CreateExpenseView', 2);

    return GetBuilder<CreateExpenseViewModel>(
      init: createExpenseVM,
      builder: (controller) {
        print("controller.selectedCategory is ${controller.selectedCategory}");
        return Container(
          height: 550.h,
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.existingExpense == null
                        ? "إنشاء بند جديد للمصروفات"
                        : "تحديث بند مصروفات",
                    style: context.typography.mdBold,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: KeyboardActions(
                  config: keyboardService.buildConfig(context, keys),
                  child: Form(
                    key: globalKeyExpense,
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        (controller.existingExpense?.totalAmount == null &&
                                    controller.isUpdate == true) ||
                                controller.existingExpense?.totalAmount ==
                                    0.0 ||
                                controller.existingExpense?.totalAmount == 0
                            ? const SizedBox()
                            : Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: CustomInputField(
                                  padding_horizontal: 0,
                                  show_asterisc: true,
                                  label: "المبلغ المطلوب",
                                  hintText: "أدخل المبلغ المطلوب",
                                  controller: controller.totalController,
                                  keyboardType: TextInputType.number,
                                  validator: InputValidators.combine([
                                    notEmptyValidator,
                                  ]),
                                  focusNode: keyboardService.getFocusNode(
                                    keys[0],
                                  ),
                                ),
                              ),

                        // Invoice Total
                        controller.existingExpense?.pending_amount == null ||
                                controller.existingExpense?.pending_amount ==
                                    0.0 ||
                                controller.existingExpense?.pending_amount == 0
                            ? const SizedBox()
                            : Padding(
                                padding: EdgeInsets.only(
                                  top: 10.h,
                                  bottom: 15.h,
                                ),
                                child: CustomInputField(
                                  padding_horizontal: 0,
                                  show_asterisc: false,
                                  label: "إجمالي المبلغ المراد دفعة",
                                  voidCallbackAction: (value) {
                                    controller.validateStep();
                                    controller.update();
                                  },
                                  hintText: "إجمالي المبلغ المراد دفعة",
                                  controller: controller.needToPayController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: InputValidators.combine([
                                    notEmptyValidator,
                                    // (
                                    //   value,
                                    // ) => InputValidators.validateNumberAndMax(
                                    //   value,
                                    //   max: controller.totalInvoiceAmount.toInt(),
                                    //   errorMessage:
                                    //       "القيمة يجب أن تكون رقماً وأقل من أو تساوي ${controller.totalInvoiceAmount}",
                                    // ),
                                  ]),
                                  focusNode: keyboardService.getFocusNode(
                                    keys[1],
                                  ),
                                ),
                              ),

                        // Expense Type
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: GenericDropdown<GenericListModel>(
                            hint_text: "اختر نوع بند المصروفات",
                            title: "نوع بند المصروفات",
                            items: controller.categoryList,
                            initialValue: controller.selectedCategory,
                            onChanged: (value) {
                              controller.selectedCategory = value;
                              controller.update();
                            },
                            displayItemBuilder: (item) => Text(
                              item.name ?? "",
                              style: context.typography.mdRegular.copyWith(
                                color: ColorMappingImpl().textLabel,
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(bottom: 8.0.h, top: 10.h),
                          child: AppText(
                            text: "تاريخ إنشاء الدفعة",
                            textStyle: context.typography.smRegular.copyWith(
                              color: ColorMappingImpl().textLabel,
                            ),
                          ),
                        ),
                        CalenderWidget(
                          onDateSelected: (timeStamp, date) {
                            controller.createAt =
                                timeStamp.millisecondsSinceEpoch;

                            final now = DateTime.now();
                            final parsedDate = DateTime.parse(date);

                            final selected = DateTime(
                              parsedDate.year,
                              parsedDate.month,
                              parsedDate.day,
                            );
                            final today = DateTime(
                              now.year,
                              now.month,
                              now.day,
                            );

                            if (selected.isAfter(today)) {
                              // 🔔 Future date → Reminder (coming)
                              controller.selectedPaymentMethod = controller
                                  .listPayments
                                  .firstWhere(
                                    (e) => e.key == BilesStatus.comming.name,
                                    orElse: () => controller.listPayments.first,
                                  );
                            } else {
                              // 💵 Today or past → Cash/Done (finished)
                              controller.selectedPaymentMethod = controller
                                  .listPayments
                                  .firstWhere(
                                    (e) => e.key == BilesStatus.finished.name,
                                    orElse: () => controller.listPayments.first,
                                  );
                            }

                            controller.update();
                          },

                          initialTimestamp: controller.selectedDateTimestamp,

                          hintText: "تاريخ إنشاء الدفعة",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(height: 20.h),
              SafeArea(
                child: BottomNavigationActions(
                  rightTitle: controller.isUpdate == true
                      ? "تحديث بند المصروفات"
                      : "إنشاء بند المصروفات",
                  rightAction: controller.saveExpense,
                  isRightEnabled: controller.validateStep(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
