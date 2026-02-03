import '../../../../index/index_main.dart';

class OrderController extends GetxController {
  // 🔹 All orders fetched from Firebase
  List<OrderModel?>? allOrders = [];

  // 🔹 Categorized orders
  List<OrderModel?> comingOrders = [];
  List<OrderModel?> finishedOrders = [];

  // 🔹 Summary
  double totalMonthProfit = 0;
  bool isLoading = false;

  // ------------------------------------------------------------------
  // 🔹 Commission percentage (UPDATED → 5%)
  // ------------------------------------------------------------------
  double commissionRate = 0.05;
  String commissionLabel = "نسبة الربح (5٪)";

  @override
  void onInit() {
    super.onInit();

    final user = LocalUser().getUserData();
    final isDoctor = user.userType?.name == "doctor";

    if (isDoctor) {
      commissionRate = 0.05;
      commissionLabel = "نسبة الدكتور (5٪)";
    } else {
      commissionRate = 0.05;
      commissionLabel = "نسبة المساعد (5٪)";
    }
  }

  // ------------------------------------------------------------------
  // 🔹 incentive tiers (UPDATED → 5%)
  // ------------------------------------------------------------------
  List<Map<String, dynamic>> getIncentiveTiers() {
    const pricePerOrder = 200.0;

    const baseRate = 0.05; // 5%
    const weeklyDays = 6;
    const monthlyDays = 26;

    final tiers = [5, 10, 15];

    return tiers.map((count) {
      final revenue = count * pricePerOrder;

      final weekly = revenue * baseRate * weeklyDays;
      final monthly = revenue * baseRate * monthlyDays;

      return {
        "orders": count,

        "avg_weekly": weekly,
        "inc_weekly": 0.0,
        "total_weekly": weekly,

        "avg_monthly": monthly,
        "inc_monthly": 0.0,
        "total_monthly": monthly,
      };
    }).toList();
  }

  // ------------------------------------------------------------------
  // 📦 Fetch Orders
  // ------------------------------------------------------------------
  Future<void> getOrders() async {
    try {
      isLoading = true;
      update();

      final user = LocalUser().getUserData();
      final userKey = user.doctorKey ?? "";

      const filterField = "doctor_key";

      await OrderService().getOrdersData(
        data: {"orderBy": "\"$filterField\"", "equalTo": "\"$userKey\""},
        filrebaseFilter: FirebaseFilter(orderBy: filterField, equalTo: userKey),
        voidCallBack: (data) {
          allOrders = data;
          _categorize();
          _calculateProfit();
        },
      );
    } catch (e) {
      Loader.showError("⚠️ خطأ أثناء تحميل الطلبات: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  // ------------------------------------------------------------------
  // 🚚 Categorize orders
  // ------------------------------------------------------------------
  void _categorize() {
    comingOrders = [];
    finishedOrders = [];

    for (var o in allOrders ?? []) {
      if (o == null) continue;

      final status = o.status?.toLowerCase() ?? "";
      final transfer = o.isTransfered ?? 0;

      if (status == "completed" || status == "finished") {
        if (transfer == 0) {
          comingOrders.add(o);
        } else {
          finishedOrders.add(o);
        }
      }
    }
  }

  // ------------------------------------------------------------------
  // 💰 Calculate Monthly Profit
  // ------------------------------------------------------------------
  void _calculateProfit() {
    totalMonthProfit = 0;
    final now = DateTime.now();

    for (var o in finishedOrders) {
      if (o == null) continue;

      final date = DateTime.fromMillisecondsSinceEpoch(o.createdAt ?? 0);
      if (date.month == now.month && date.year == now.year) {
        totalMonthProfit += (o.totalOrder ?? 0) * commissionRate;
      }
    }
  }

  // ------------------------------------------------------------------
  // 💵 Profit per order (UPDATED → 5%)
  // ------------------------------------------------------------------
  double getOrderProfit(OrderModel order) {
    return (order.totalOrder ?? 0) * commissionRate;
  }

  Future<void> refreshOrders() async {
    await getOrders();
  }
}
