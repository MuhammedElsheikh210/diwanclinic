import '../../../index/index_main.dart';

class ExpenseCardWidget extends StatelessWidget {
  final TransactionsEntity? transactionsEntity;
  final ExpenseViewModel controller;
  final bool? isFromHome;

  const ExpenseCardWidget({
    required this.transactionsEntity,
    required this.controller,
    this.isFromHome,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(color: ColorMappingImpl().borderNeutralPrimary),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Status Badge
          HeaderWidget(
            name: transactionsEntity?.transactionType == "expense"
                ? transactionsEntity?.expenseCategoryName ?? ""
                : transactionsEntity?.bileTitle ?? "بند المصروف",
            title: ": نوع المصروف",
            status_label: transactionsEntity?.status,
            status_name: transactionsEntity?.statusKey?.toLowerCase() ?? "",
          ),

          const SizedBox(height: 10),
          // Paid Amount
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: MerchantListTileWidget(
                    icon: IconsConstants.payment_type,
                    showLeading: true,
                    title:
                        transactionsEntity?.statusKey ==
                                BilesStatus.comming.name ||
                            transactionsEntity?.statusKey ==
                                Strings.not_paid_key
                        ? "المبلغ المطلوب"
                        : "المبلغ المدفوع",
                    body:
                        "${transactionsEntity?.statusKey == BilesStatus.comming.name || transactionsEntity?.statusKey == Strings.not_paid_key ? transactionsEntity?.pending_amount : transactionsEntity?.totalAmount ?? "0"} ج.م",
                  ),
                ),
                Expanded(
                  child: MerchantListTileWidget(
                    icon: IconsConstants.payment_type,
                    showLeading: false,
                    title: "بند المصروفات",
                    body: transactionsEntity?.expenseCategoryName ?? "",
                  ),
                ),
              ],
            ),
          ),

          // Wallet Name (Paid From)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                // Expense Date
                Expanded(
                  child: MerchantListTileWidget(
                    icon: IconsConstants.calendar,
                    showLeading: true,
                    title: "تاريخ الدفع",
                    body: DatesUtilis.convertTimestamp(
                      transactionsEntity?.createAt ?? 0,
                    ),
                  ),
                ),
                Expanded(
                  child: MerchantListTileWidget(
                    icon: IconsConstants.sales,
                    showLeading: false,
                    title: "الحساب المدفوع منه",
                    body: transactionsEntity?.walletName ?? "غير محدد",
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
              left: 8.0.w,
              bottom: 10.h,
              top: 10.h,
              right: 8.w,
            ),
            child: TransactionStatusButtonsWidget(
              transactionsEntity: transactionsEntity,
              showDeleteEdit:
                  transactionsEntity?.statusKey == BilesStatus.finished.name
                  ? false
                  : true,
              onPay: () {
                transactionsEntity?.status = BilesStatus.finished.value;
                transactionsEntity?.statusKey = BilesStatus.finished.name;
                transactionsEntity?.totalAmount =
                    transactionsEntity?.pending_amount;
                transactionsEntity?.pending_amount = 0.0;
                processTransaction(transactionsEntity ?? TransactionsEntity());
              },

              onDetails: () {
                // showCustomBottomSheet(
                //   context: context,
                //   child: BilesDetailsView(
                //     transactionsEntity: transactionsEntity,
                //   ),
                // );
              },
              onEdit: () {
                if (transactionsEntity?.status == "منتهية" ||
                    transactionsEntity?.status == "ملغي") {
                  Loader.showInfo("المصروفات المنتهية لايمكن تعديلها ");
                } else {
                  Get.delete<CreateExpenseViewModel>();
                  showCustomBottomSheet(
                    context: context,
                    child: CreateExpenseView(expenseEntity: transactionsEntity),
                  );
                }
              },
              onDelete: () {
                controller.deleteExpense(
                  transactionsEntity?.key ?? "",
                  transactionsEntity ?? TransactionsEntity(),
                  isFromHome,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void processTransaction(TransactionsEntity expense) {
    TransactionService().updateTransactionData(
      transaction: expense,
      voidCallBack: (status) {
        ExpenseViewModel expenseViewModel = initController(
          () => ExpenseViewModel(),
        );
        expenseViewModel.getExpenseBannerData();
        expenseViewModel.refreshCurrentTab();
        Loader.showSuccess("تمت العملية بنجاح");
      },
    );
  }
}
