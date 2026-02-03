import 'package:diwanclinic/Presentation/Widgets/drop_down/adatper/month_adapteer.dart';
import 'package:diwanclinic/Presentation/screens/expenses/expenses/lists/widget/tabs_widget.dart';

import '../../../../../index/index_main.dart';

class ExpenseView extends StatefulWidget {
  final bool? showBar;
  final bool? from_home;

  const ExpenseView({super.key, this.showBar, this.from_home});

  @override
  State<ExpenseView> createState() => _ExpenseViewState();
}

class _ExpenseViewState extends State<ExpenseView> {
  late final ExpenseViewModel controller;
  late List<GenericListModel> monthOptions;
  GenericListModel? selectedMonth;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ExpenseViewModel());
    controller.refreshCurrentTab();
    controller.getExpenseBannerData();

    // ✅ Initialize months
    monthOptions = MonthAdapter.generateMonths();
    selectedMonth = monthOptions.firstWhere(
      (m) => m.key == DateTime.now().month.toString(),
      orElse: () => monthOptions.first,
    );
    controller.selectedMonth = selectedMonth; // save in controller
    controller.update();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: GetBuilder<ExpenseViewModel>(
        init: controller,
        dispose: (_) => Get.delete<ExpenseViewModel>(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: ColorMappingImpl().white,
            floatingActionButton: InkWell(
              onTap: () {
                Get.delete<CreateExpenseViewModel>();
                showCustomBottomSheet(
                  context: context,
                  child: const CreateExpenseView(),
                );
              },
              child: const Svgicon(icon: IconsConstants.fab_Button),
            ),
            appBar: AppBar(
              backgroundColor: AppColors.white,
              title: Text(
                "سجل المصروفات الشهرية",
                style: context.typography.lgBold,
              ),
            ),
            body: Container(
              color: AppColors.white,
              child: SafeArea(
                child: RefreshIndicator(
                  color: AppColors.white,
                  backgroundColor: AppColors.primary,
                  onRefresh: () async {
                    await controller.getExpenseBannerData(); // stats
                    await controller.refreshCurrentTab();
                  },
                  child: ListView.builder(
                    itemCount: 3 + (controller.listExpense?.length ?? 0),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: GenericDropdown<GenericListModel>(
                            hint_text: "الأشهر",
                            title: "اختر الشهر",
                            items: MonthAdapter.generateMonths(),
                            initialValue: controller.selectedMonth,
                            onChanged: (value) {
                              controller.selectedMonth = value;

                              if (value?.key != null) {
                                final parts = value!.key!.split("-");
                                final year = int.tryParse(parts[0]);
                                final month = int.tryParse(parts[1]);

                                if (year != null && month != null) {
                                  controller.filterYear = year;
                                  controller.filterMonth = month;

                                  // ✅ reload with month filter
                                  controller.getExpenseBannerData();
                                  controller.refreshCurrentTab();
                                }
                              }

                              controller.update();
                            },
                            displayItemBuilder: (item) => Text(
                              item.name ?? "",
                              style: context.typography.mdRegular.copyWith(
                                color: AppColors.text_primary_paragraph,
                              ),
                            ),
                          ),
                        );
                      } else if (index == 1) {
                        return StatsBanner(
                          title: "إحصائيات المصروفات الشهرية",
                          items: [
                            StatsBannerItem(
                              title: "الإجمالي",
                              value: controller.total,
                            ),
                            StatsBannerItem(
                              title: "المدفوع",
                              value: controller.paid,
                            ),
                            StatsBannerItem(
                              title: "المتبقي",
                              value: controller.rest,
                            ),
                          ],
                        );
                      } else if (index == 2) {
                        return TabsWidget(controller: controller);
                      } else {
                        final expenseIndex = index - 3;
                        final model = controller.listExpense?[expenseIndex];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          child: ExpenseCardWidget(
                            transactionsEntity: model,
                            controller: controller,
                            isFromHome: widget.from_home,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
