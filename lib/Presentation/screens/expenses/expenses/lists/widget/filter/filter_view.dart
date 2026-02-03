import '../../../../../../../index/index_main.dart';

class FilterViewExpense extends StatefulWidget {
  const FilterViewExpense({Key? key}) : super(key: key);

  @override
  State<FilterViewExpense> createState() => _FilterViewExpenseState();
}

class _FilterViewExpenseState extends State<FilterViewExpense> {
  // New Filters
  GenericListModel? selectedExpenseType;
  Timestamp? selectedDate;

  bool isValid = false; // Track form validation
  GenericListModel? selectedMonth;
  final List<GenericListModel> monthList = List.generate(12, (index) {
    final date = DateTime.now().subtract(Duration(days: 30 * index));
    return GenericListModel(
      key: '${date.year}-${date.month}',
      name: '${date.month}-${date.year}', // You can localize the month name
    );
  });

  void validateFields() {
    setState(() {
      isValid = selectedExpenseType != null;
    });
  }

  void applyFilters() {
    // Get month/year from dropdown if selected
    int? month;
    int? year;
    if (selectedMonth != null) {
      final parts = selectedMonth!.key!.split('-'); // year-month
      year = int.parse(parts[0]);
      month = int.parse(parts[1]);
    }

    // Create filter params
    final filterParams = TransactionsEntity(
      keyExpenseCategory: selectedExpenseType?.key, // category
      sort_by:
          year != null && month != null ? '$year-$month' : null, // month-year
    );

    Navigator.pop(context, filterParams);
  }

  void resetFilters() {
    setState(() {
      selectedExpenseType = null;
      selectedDate = null;
      isValid = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: GetBuilder<ExpenseViewModel>(
        init: ExpenseViewModel(),
        builder: (controller) {
          return Column(
            children: [
              // Transparent Background to close modal on tap
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: Container(color: Colors.transparent),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 400.h,
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        const BottomSheetAppBar(title: 'تصفية المصروفات'),

                        // Expense Type
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: GenericDropdown<GenericListModel>(
                            hint_text: "اختر نوع بند المصروفات",
                            title: "نوع بند المصروفات",
                            items: controller.categoryList,
                            initialValue: controller.selectedCategory,
                            onChanged: (value) {
                              setState(() {
                                selectedExpenseType = value;
                                validateFields();
                              });
                            },
                            displayItemBuilder:
                                (item) => Text(
                                  item.name ?? "",
                                  style: context.typography.mdRegular.copyWith(
                                    color: ColorMappingImpl().textLabel,
                                  ),
                                ),
                          ),
                        ),

                        // Padding(
                        //   padding: EdgeInsets.only(bottom: 5.0.h),
                        //   child: Text(
                        //     "تاريخ الدفع",
                        //     style: context.typography.mdMedium,
                        //   ),
                        // ),
                        // // Date Picker
                        // CalenderWidget(
                        //   onDateSelected: (timeStamp, date) {
                        //     setState(() {
                        //       selectedDate = timeStamp ;
                        //     });
                        //   },
                        //   initialTimestamp:
                        //       DateTime.now().millisecondsSinceEpoch,
                        //   hintText: "تاريخ التحويل",
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: GenericDropdown<GenericListModel>(
                            hint_text: "اختر الشهر",
                            title: "الشهر",
                            items: monthList,
                            initialValue: selectedMonth,
                            onChanged: (value) {
                              setState(() {
                                selectedMonth = value;
                                validateFields();
                              });
                            },
                            displayItemBuilder:
                                (item) => Text(
                                  item.name ?? "",
                                  style: context.typography.mdRegular.copyWith(
                                    color: ColorMappingImpl().textLabel,
                                  ),
                                ),
                          ),
                        ),

                        // Apply Filter Button
                        Padding(
                          padding: EdgeInsets.only(top: 30.0.h),
                          child: PrimaryTextButton(
                            customBackgroundColor: ColorMappingImpl().textLabel,
                            appButtonSize: AppButtonSize.xlarge,
                            onTap: isValid ? applyFilters : null,
                            label: AppText(
                              text: "تصفية النتائج",
                              textStyle: context.typography.mdMedium.copyWith(
                                color: ColorMappingImpl().white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
