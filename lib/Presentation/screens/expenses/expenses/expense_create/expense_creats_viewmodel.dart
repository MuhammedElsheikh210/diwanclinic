import 'package:diwanclinic/Presentation/Widgets/drop_down/adatper/category_adapter.dart';

import '../../../../../index/index_main.dart';

class CreateExpenseViewModel extends GetxController {
  bool isRepeatEnabled = false;
  final TextEditingController totalController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController needToPayController = TextEditingController();

  List<GenericListModel> repeatFrequencyList = [
    GenericListModel(id: 0, name: "يومي", key: "daily", totalAmount: "1"),
    GenericListModel(id: 1, name: "أسبوعي", key: "weekly", totalAmount: "7"),
    GenericListModel(id: 2, name: "شهري", key: "monthly", totalAmount: "30"),
  ];

  GenericListModel? selectedRepeatFrequency;
  int? selectedDateTimestamp;

  List<GenericListModel> categoryList = [];
  GenericListModel? selectedCategory;

  bool? isUpdate;
  TransactionsEntity? existingExpense;
  int? createAt = DateTime.now().millisecondsSinceEpoch;
  double totalInvoiceAmount = 0;

  List<GenericListModel> listPayments = [
    GenericListModel(id: 0, name: "دفع نقدي", key: BilesStatus.finished.name),
    GenericListModel(
      id: 1,
      name: "تنيه بميعاد الفاتورة",
      key: BilesStatus.comming.name,
    ),
  ];
  GenericListModel? selectedPaymentMethod;

  @override
  Future<void> onInit() async {
    selectedDateTimestamp = DateTime.now().millisecondsSinceEpoch;
    await getWalletData();
    await getCategoryList();
    // to update
    if (existingExpense != null) {
      existingExpense = existingExpense;
      isUpdate = existingExpense != null ? true : false;
      populateFields(existingExpense ?? TransactionsEntity());
    }
    update();
    super.onInit();
  }

  Future<void> getCategoryList() async {
    await CategoryService().getAllCategoriesData(
      filterParams: SQLiteQueryParams(),
      voidCallBack: (data) {
        categoryList = CategoryModelAdapterUtil.convertCategoryListToGeneric(
          data,
        );
        update();
      },
    );
  }

  void populateFields(TransactionsEntity expense) {
    nameController.text = expense.invoiceTitle ?? "";
    totalController.text = (expense.totalAmount ?? 0).toString();
    needToPayController.text = (expense.pending_amount ?? 0).toString();

    // ✅ set the max allowed for validation
    totalInvoiceAmount =
        (expense.pending_amount ?? expense.totalAmount ?? 0).toDouble();

    selectedDateTimestamp = expense.createAt;

    print("selectedCategory is ${selectedCategory?.name}");
    update();
  }

  Future<void> getWalletData() async {
    // await WalletService().getAllWalletsData(
    //   voidCallBack: (value) {
    //     listAccounts = value;
    //     listWallets = WalletsModelAdapterUtil.convertWalletListToGeneric(value);
    //     update();
    //   },
    // );
  }

  double getRestAmount(String amount) {
    double paid = double.tryParse(amount) ?? 0;
    return totalInvoiceAmount - paid;
  }

  void saveExpense() {
    final double billAmount = double.tryParse(totalController.text) ?? 0.0;
    final double pendingAmount =
        double.tryParse(needToPayController.text) ?? 0.0;

    final TransactionsEntity expense =
        existingExpense?.copyWith(
          keyExpenseCategory: selectedCategory?.key,
          expenseCategoryName: selectedCategory?.name,
          transactionType: TransactionEnum.expense.name,
          totalAmount: billAmount,
          pending_amount: pendingAmount,
          isRepeatExpense: isRepeatEnabled == false ? 0 : 1,
          repeatValue: int.tryParse(selectedRepeatFrequency?.totalAmount ?? ""),
          createAt: createAt, // ✅ enforce selected date
        ) ??
        TransactionsEntity(
          key: const Uuid().v4(),
          uid: Get.find<UserSession>().user?.uid,
          createAt: createAt ?? DateTime.now().millisecondsSinceEpoch,
          // ✅ use picked date
          isRepeatExpense: 0,
          keyExpenseCategory: selectedCategory?.key,
          expenseCategoryName: selectedCategory?.name,
          expenseCategoryType: selectedCategory?.category_type,
          transactionType: TransactionEnum.expense.name,
          totalAmount:
              selectedPaymentMethod?.id == 0 || selectedPaymentMethod == null
                  ? billAmount
                  : null,
          pending_amount: selectedPaymentMethod?.id == 1 ? billAmount : null,
          statusKey:
              selectedPaymentMethod?.id == 1
                  ? BilesStatus.comming.name
                  : BilesStatus.finished.name,
          status:
              selectedPaymentMethod?.id == 1
                  ? BilesStatus.comming.value
                  : BilesStatus.finished.value,
        );

    isUpdate == true ? _updateExpense(expense) : _createExpense(expense);
  }

  void _createExpense(TransactionsEntity expense) {
    TransactionService().addTransactionData(
      transaction: expense,
      voidCallBack: (status) {
        Get.back();
        ExpenseViewModel expenseViewModel = initController(
          () => ExpenseViewModel(),
        );
        expenseViewModel.getExpenseBannerData();
        expenseViewModel.refreshCurrentTab();
        Loader.showSuccess("تم إضافة المصروف بنجاح");
      },
    );
  }

  void _updateExpense(TransactionsEntity expense) {
    TransactionService().updateTransactionData(
      transaction: expense,
      voidCallBack: (_) {
        _refreshExpense();

        Loader.showSuccess("تم التحديث بنجاح");
      },
    );
  }

  void _refreshExpense({int? tab_index}) {
    Get.back();

    // Use the existing controller if already in memory
    final expenseVM =
        Get.isRegistered<ExpenseViewModel>()
            ? Get.find<ExpenseViewModel>()
            : initController(() => ExpenseViewModel());

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfNextMonth = DateTime(
      now.year,
      now.month + 1,
      1,
    ); // auto-rollover

    final startTs = startOfMonth.millisecondsSinceEpoch;
    final endTs = startOfNextMonth.millisecondsSinceEpoch;

    final tab = tab_index ?? 0;
    expenseVM.tab_index = tab;

    // Base WHERE + args (month & type)
    String where = 'transaction_type = ? AND create_at >= ? AND create_at < ?';
    final args = <Object?>[TransactionEnum.expense.name, startTs, endTs];

    // Status filter
    if (tab == 1) {
      // Finished only
      where += ' AND status_key = ?';
      args.add(BilesStatus.finished.name);
    } else {
      // Upcoming: coming OR not_paid
      where += ' AND status_key IN (?, ?)';
      args.addAll([BilesStatus.comming.name, BilesStatus.not_paid.name]);
    }

    expenseVM.getData(
      SQLiteQueryParams(
        orderBy: 'create_at ${Strings.asc}',
        where: where,
        whereArgs: args,
        is_filtered: true,
      ),
    );

    expenseVM.getExpenseBannerData();
    expenseVM.update();
  }

  bool validateStep() {
    return (totalController.text.isNotEmpty ||
            needToPayController.text.isNotEmpty) &&
        createAt != null;
  }

  @override
  void dispose() {
    totalController.dispose();
    needToPayController.dispose();
    nameController.dispose();
    super.dispose();
  }
}
