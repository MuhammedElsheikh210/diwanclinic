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
          backgroundColor: AppColors.grayLight.withValues(alpha: 0.2),
          appBar: AppBar(
            title: Text("الأرباح", style: context.typography.lgBold),
            backgroundColor: AppColors.white,
            elevation: 1,
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildTodaySummary(controller, context),
                    _buildMonthlySummary(controller, context),
                    const SizedBox(height: 10),
                    _buildTabs(context, controller),
                  ],
                ),
        );
      },
    );
  }

  // ============================================================
  // 🟢 ملخص اليوم
  // ============================================================

  Widget _buildTodaySummary(OrderController controller, BuildContext context) {
    final completedToday = controller.finishedOrders.where((o) {
      if (o == null) return false;
      final date = DateTime.fromMillisecondsSinceEpoch(o.createdAt ?? 0);
      final now = DateTime.now();
      return date.day == now.day &&
          date.month == now.month &&
          date.year == now.year;
    }).length;

    final activated = completedToday >= 3;
    final remaining = activated ? 0 : (3 - completedToday);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
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
          Text("📅 أرباح اليوم", style: context.typography.lgBold),
          const SizedBox(height: 12),

          _infoRow("عدد الطلبات المكتملة", "$completedToday", context),

          const SizedBox(height: 6),

          activated
              ? Text(
                  "✔ تم تفعيل العمولة (5٪ على جميع الطلبات)",
                  style: context.typography.mdMedium.copyWith(
                    color: AppColors.successForeground,
                  ),
                )
              : Text(
                  "باقي $remaining طلب لتفعيل العمولة",
                  style: context.typography.mdMedium.copyWith(
                    color: Colors.orange,
                  ),
                ),

          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 10),

          _infoRow(
            "💰 عمولة اليوم",
            "${controller.todayProfit.toStringAsFixed(2)} ج.م",
            context,
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🟢 ملخص الشهر
  // ============================================================

  Widget _buildMonthlySummary(
    OrderController controller,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: _infoRow(
        "💵 إجمالي عمولة الشهر",
        "${controller.totalMonthProfit.toStringAsFixed(2)} ج.م",
        context,
        isHighlight: true,
      ),
    );
  }

  // ============================================================
  // 🟢 Tabs
  // ============================================================

  Widget _buildTabs(BuildContext context, OrderController controller) {
    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                labelStyle: context.typography.mdBold,
                unselectedLabelStyle: context.typography.mdMedium,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: "مكتملة"),
                  Tab(text: "قيد التنفيذ"),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  _orderList(context, controller.finishedOrders),
                  _orderList(context, controller.comingOrders),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🟢 قائمة الطلبات
  // ============================================================

  Widget _orderList(BuildContext context, List<OrderModel?> orders) {
    final controller = Get.find<OrderController>();

    if (orders.isEmpty) {
      return Center(
        child: Text("لا توجد طلبات حالياً", style: context.typography.mdMedium),
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

        final profit = controller.getOrderProfit(o);
        final activated = profit > 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow("إجمالي الروشتة", "$net ج.م", context),
              const SizedBox(height: 6),

              _infoRow(
                activated ? "عمولتك من هذا الطلب" : "العمولة",
                activated
                    ? "${profit.toStringAsFixed(2)} ج.م"
                    : "لم يتحقق التارجت",
                context,
                isHighlight: activated,
              ),

              const SizedBox(height: 10),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text("تاريخ: $date", style: context.typography.smRegular),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // 🟢 Row Helper
  // ============================================================

  Widget _infoRow(
    String label,
    String value,
    BuildContext context, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.typography.mdMedium),
        Text(
          value,
          style: context.typography.mdBold.copyWith(
            color: isHighlight ? AppColors.primary : AppColors.background_black,
          ),
        ),
      ],
    );
  }
}
