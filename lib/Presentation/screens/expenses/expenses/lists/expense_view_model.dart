import 'package:diwanclinic/Presentation/Widgets/drop_down/adatper/category_adapter.dart';
import 'package:diwanclinic/Presentation/screens/expenses/expenses/lists/widget/filter/filter_view.dart';
import 'package:diwanclinic/Presentation/screens/expenses/expenses/status.dart';

import '../../../../../index/index_main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ExpenseViewModel extends GetxController {
  int tab_index = 0;
  List<TransactionsEntity?>? listExpense; // For current tab (UI list)
  List<TransactionsEntity?>? listExpenseForBanner; // For stats banner

  bool isExpand = true;
  List<GenericListModel> listWallets = [];
  List<TransactionsEntity?>? listExpense_statistics;
  List<CategoryEntity?>? listCategories;
  double total = 0.0;
  double paid = 0.0;
  double rest = 0.0;
  GenericListModel? selectedMonth;

  GenericListModel? selectedPaymentMethod;
  GenericListModel? selectedexpenseStatus;

  // Expense Type Options
  List<GenericListModel> categoryList = [];
  GenericListModel? selectedCategory;

  // -----------------------------
  // 🔹 Month filter (optional)
  // -----------------------------
  int? filterMonth; // 1..12
  int? filterYear; // e.g., 2025

  // ----- Date window (uses filter if provided, otherwise current month) -----
  int get _startTs {
    final now = DateTime.now();
    final y = filterYear ?? now.year;
    final m = filterMonth ?? now.month;
    return DateTime(y, m, 1).millisecondsSinceEpoch;
  }

  int get _endTs {
    final now = DateTime.now();
    final y = filterYear ?? now.year;
    final m = filterMonth ?? now.month;
    return DateTime(y, m + 1, 1).millisecondsSinceEpoch;
  }

  // ----- Status filters (with date range) -----
  String get _whereUpcoming =>
      'transaction_type = ? AND status_key IN (?, ?) AND create_at >= ? AND create_at < ?';

  List<Object?> get _argsUpcoming => [
    TransactionEnum.expense.name,
    BilesStatus.comming.name,
    BilesStatus.not_paid.name,
    _startTs,
    _endTs,
  ];

  String get _whereFinished =>
      'transaction_type = ? AND status_key = ? AND create_at >= ? AND create_at < ?';

  List<Object?> get _argsFinished => [
    TransactionEnum.expense.name,
    BilesStatus.finished.name,
    _startTs,
    _endTs,
  ];

  Future<void> getExpenseBannerData() async {
    TransactionService().getAllTransactionsData(
      voidCallBack: (data) {
        listExpenseForBanner = data;
        print("listExpenseForBanner is ${listExpenseForBanner?.length}");
        _calculateStatistics(listExpenseForBanner); // stats use all
        update();
      },
      filter: SQLiteQueryParams(
        orderBy: 'create_at ${Strings.desc}',
        where: 'transaction_type = ? AND create_at >= ? AND create_at < ?',
        whereArgs: [TransactionEnum.expense.name, _startTs, _endTs],
        is_filtered: true,
      ),
    );
  }

  Future<void> refreshCurrentTab() async {
    final isUpcoming = tab_index == 0;

    TransactionService().getAllTransactionsData(
      voidCallBack: (data) {
        listExpense = data; // only filtered for tab
        update();
      },
      filter: SQLiteQueryParams(
        orderBy: 'create_at ${Strings.desc}',
        where: isUpcoming ? _whereUpcoming : _whereFinished,
        whereArgs: isUpcoming ? _argsUpcoming : _argsFinished,
        is_filtered: true,
      ),
    );
  }

  @override
  Future<void> onInit() async {
    super.onInit();
  }

  Future<void> deleteAllTransactionsForCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseDatabase.instance.ref(
      'on5ZrGXZycY3o0yPDi3kinWVpg13/transactions',
    );
    await ref.remove();
  }

  void tabsActions(int index) {
    tab_index = index;
    refreshCurrentTab();
    update();
  }

  Future<void> showFilterBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      elevation: 1,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterViewExpense(),
    );

    if (result is TransactionsEntity) {
      int? filterYear;
      int? filterMonth;

      // Extract month/year if provided
      if (result.sort_by != null && result.sort_by!.contains('-')) {
        final parts = result.sort_by!.split('-');
        filterYear = int.tryParse(parts[0]);
        filterMonth = int.tryParse(parts[1]);
      }

      final isUpcoming = tab_index == 0;

      // Build WHERE clause dynamically
      String whereClause = isUpcoming
          ? 'transaction_type = ? AND status_key IN (?, ?)'
          : 'transaction_type = ? AND status_key = ?';

      List<Object?> whereArgs = isUpcoming
          ? [
              TransactionEnum.expense.name,
              BilesStatus.comming.name,
              BilesStatus.not_paid.name,
            ]
          : [TransactionEnum.expense.name, BilesStatus.finished.name];

      // Add category filter if selected
      if (result.keyExpenseCategory != null) {
        whereClause += ' AND key_expense_category = ?';
        whereArgs.add(result.keyExpenseCategory);
      }

      // Add date filter if month/year selected
      if (filterYear != null && filterMonth != null) {
        whereClause += ' AND create_at >= ? AND create_at < ?';
        whereArgs.add(
          DateTime(filterYear, filterMonth, 1).millisecondsSinceEpoch,
        );
        whereArgs.add(
          DateTime(filterYear, filterMonth + 1, 1).millisecondsSinceEpoch,
        );
      }

      getData(
        SQLiteQueryParams(
          orderBy: 'create_at ${Strings.desc}',
          where: whereClause,
          whereArgs: whereArgs,
          is_filtered: true,
        ),
      );
    }
  }

  void getData(SQLiteQueryParams query) {
    TransactionService().getAllTransactionsData(
      voidCallBack: (data) {
        final now = DateTime.now().millisecondsSinceEpoch;

        final updatedData = data.map((expense) {
          if ((expense?.statusKey == BilesStatus.comming.name ||
                  expense?.statusKey == BilesStatus.not_paid.name) &&
              (expense?.createAt ?? 0) < now) {
            return expense?.copyWith(
              status: BilesStatus.not_paid.value,
              statusKey: BilesStatus.not_paid.name,
            );
          }
          return expense;
        }).toList();

        listExpense = updatedData;

        // ✅ Calculate monthly stats
        _calculateStatistics(listExpense);

        update();
      },
      filter: query,
    );
  }

  void _calculateStatistics(List<TransactionsEntity?>? source) {
    final totalPaid = (source ?? []).fold<double>(
      0.0,
      (sum, e) => sum + (e?.totalAmount ?? 0).toDouble(),
    );

    final totalPending = (source ?? []).fold<double>(
      0.0,
      (sum, e) => sum + (e?.pending_amount ?? 0).toDouble(),
    );

    total = totalPaid + totalPending;
    paid = totalPaid;
    rest = total - paid;
  }

  void deleteExpense(
    String key,
    TransactionsEntity expenseEntity,
    bool? isFromHome,
  ) {
    TransactionService().deleteTransactionData(
      transactionKey: key,
      voidCallBack: (_) {
        ExpenseViewModel expenseViewModel = initController(
          () => ExpenseViewModel(),
        );
        expenseViewModel.getExpenseBannerData();
        expenseViewModel.refreshCurrentTab();
        Loader.showSuccess("تمت عملية الحذف بنجاح");
      },
    );
  }

  void updateExpense(
    TransactionsEntity expenseEntity,
    bool? isFromHome, {
    bool? isCancel,
  }) {
    TransactionService().updateTransactionData(
      transaction: expenseEntity,
      voidCallBack: (_) {
        if (isCancel != true) {}
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
