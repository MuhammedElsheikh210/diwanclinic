import 'package:diwanclinic/Presentation/screens/orders/list/order_view_model.dart';
import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  late final OrderController controller;
  bool _showIncentive = false;

  @override
  void initState() {
    controller = initController(() => OrderController());
    controller.getOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
      init: controller,
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColors.grayLight.withValues(alpha: 0.3),
          appBar: AppBar(
            title: Text("ألارباح", style: context.typography.lgBold),
            backgroundColor: AppColors.white,
            elevation: 1,
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildIncentiveHeader(context),
                    _buildIncentiveTable(controller, context),

                    _buildTabs(context, controller),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildIncentiveHeader(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showIncentive = !_showIncentive),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("المرتبااااااات", style: context.typography.lgBold),
            AnimatedRotation(
              turns: _showIncentive ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.expand_more, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncentiveTable(
    OrderController controller,
    BuildContext context,
  ) {
    if (!_showIncentive) return const SizedBox.shrink();

    final tiers = controller.getIncentiveTiers();
    final headerStyle = context.typography.smRegular;
    final cellStyle = context.typography.smRegular;

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 250),
      crossFadeState: _showIncentive
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: const SizedBox.shrink(),
      secondChild: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.1),
            1: FlexColumnWidth(1.2),
            2: FlexColumnWidth(1.2),
            3: FlexColumnWidth(1.3),
            4: FlexColumnWidth(1.3),
          },
          border: const TableBorder(
            horizontalInside: BorderSide(color: Colors.grey, width: 0.2),
          ),
          children: [
            // HEADER
            TableRow(
              children: [
                _cell("الطلبات\nيوميا", headerStyle),
                _cell("متوسط\nأسبوعي", headerStyle),
                _cell("الدخل\nالشهري", headerStyle),
              ],
            ),

            // DATA ROWS
            for (var t in tiers)
              TableRow(
                children: [
                  _cell("${t['orders']}", cellStyle),
                  _cell("${t['avg_weekly'].toStringAsFixed(0)} ج.م", cellStyle),
                  _cell(
                    "${t['total_monthly'].toStringAsFixed(0)} ج.م",
                    cellStyle,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _cell(
    String text,
    TextStyle style, {
    TextAlign align = TextAlign.center,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        textAlign: align,
        style: style.copyWith(color: Colors.black87),
      ),
    );
  }

  Widget _buildTabs(BuildContext context, OrderController controller) {
    final colors = ColorMappingImpl();

    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // 🔹 Styled TabBar Container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: colors.background_neutral_100,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                labelColor: AppColors.white,
                unselectedLabelColor: colors.textSecondaryParagraph,
                labelStyle: context.typography.mdBold,
                unselectedLabelStyle: context.typography.mdMedium,
                dividerColor: Colors.transparent,
                // ✅ يخفي الخط السفلي تمامًا
                indicatorColor: Colors.transparent,
                // ✅ لا يُظهر أي خط تحتي
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.successForeground],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelPadding: const EdgeInsets.symmetric(vertical: 10),
                tabs: const [
                  Tab(text: "القادمة"),
                  Tab(text: "المنتهية"),
                ],
              ),
            ),

            // 🔹 Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  _orderList(context, controller.comingOrders),
                  _orderList(context, controller.finishedOrders),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderList(BuildContext context, List<OrderModel?> orders) {
    final colors = ColorMappingImpl();
    final controller = Get.find<OrderController>();

    if (orders.isEmpty) {
      return Center(
        child: AppText(
          text: "لا توجد طلبات حالياً",
          textStyle: context.typography.mdMedium.copyWith(
            color: colors.textSecondaryParagraph,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: orders.length,
      itemBuilder: (_, i) {
        final o = orders[i]!;
        final date = DateFormat(
          'dd MMM yyyy',
          'ar',
        ).format(DateTime.fromMillisecondsSinceEpoch(o.createdAt ?? 0));

        final total = o.totalOrder ?? 0;
        final discount = o.discount ?? 0;
        final delivery = o.deliveryFees ?? 0;
        final net = total - discount + delivery;

        // 🔹 Dynamic profit based on user role
        final profit = controller.getOrderProfit(o);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.borderNeutralPrimary.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row(
                "إجمالي الروشتة ",
                "$net ج.م",
                context,
                AppColors.background_black,
              ),
              const SizedBox(height: 6),

              // 🔹 Dynamic label and percentage
              _row(
                controller.commissionLabel,
                "${profit.toStringAsFixed(2)} ج.م",
                context,
                AppColors.successForeground,
              ),

              const SizedBox(height: 12),
              Divider(
                color: colors.borderNeutralPrimary,
                thickness: 0.5,
                height: 16,
              ),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.grayMedium,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  AppText(
                    text: "تاريخ: $date",
                    textStyle: context.typography.smRegular.copyWith(
                      color: colors.textSecondaryParagraph,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String label, String value, BuildContext context, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          text: label,
          textStyle: context.typography.smRegular.copyWith(
            color: Colors.black54,
          ),
        ),
        AppText(
          text: value,
          textStyle: context.typography.mdBold.copyWith(color: color),
        ),
      ],
    );
  }
}
