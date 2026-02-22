import '../../../../index/index_main.dart';

class OrderController extends GetxController {
  // 🔹 All orders fetched from Firebase
  List<OrderModel?>? allOrders = [];

  // 🔹 Categorized orders
  List<OrderModel?> comingOrders = [];
  List<OrderModel?> finishedOrders = [];

  // 🔹 Summary
  double totalMonthProfit = 0;
  double todayProfit = 0;

  bool isLoading = false;

  // 🔹 Commission
  double commissionRate = 0.05;
  String commissionLabel = "نسبة العمولة (5٪)";

  @override
  void onInit() {
    super.onInit();

    final user = LocalUser().getUserData();
    final isDoctor = user.userType?.name == "doctor";

    commissionRate = 0.05;

    commissionLabel =
    isDoctor ? "نسبة الدكتور (5٪)" : "نسبة المساعد (5٪)";
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
        filrebaseFilter: FirebaseFilter(
          orderBy: filterField,
          equalTo: userKey,
        ),
        voidCallBack: (data) {
          allOrders = data;
          _categorize();
          _calculateMonthlyProfit();
          _calculateTodayProfit();
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
  // 💰 Calculate Today Profit (NEW RULE)
  // ------------------------------------------------------------------
  void _calculateTodayProfit() {
    todayProfit = 0;

    final now = DateTime.now();

    final todayOrders = finishedOrders.where((o) {
      if (o == null) return false;
      final date = DateTime.fromMillisecondsSinceEpoch(o.createdAt ?? 0);
      return date.day == now.day &&
          date.month == now.month &&
          date.year == now.year;
    }).toList();

    if (todayOrders.length >= 3) {
      double total = 0;

      for (var o in todayOrders) {
        total += (o?.totalOrder ?? 0);
      }

      todayProfit = total * commissionRate;
    }
  }

  // ------------------------------------------------------------------
  // 💰 Calculate Monthly Profit (based on daily rule)
  // ------------------------------------------------------------------
  void _calculateMonthlyProfit() {
    totalMonthProfit = 0;

    final now = DateTime.now();

    // 🔹 نجمع الأوردرات حسب اليوم
    final Map<String, List<OrderModel?>> groupedByDay = {};

    for (var o in finishedOrders) {
      if (o == null) continue;

      final date = DateTime.fromMillisecondsSinceEpoch(o.createdAt ?? 0);

      if (date.month == now.month && date.year == now.year) {
        final key = "${date.year}-${date.month}-${date.day}";

        groupedByDay.putIfAbsent(key, () => []);
        groupedByDay[key]!.add(o);
      }
    }

    // 🔹 نحسب عمولة كل يوم حسب القاعدة
    for (var dailyOrders in groupedByDay.values) {
      if (dailyOrders.length >= 3) {
        double total = 0;

        for (var o in dailyOrders) {
          total += (o?.totalOrder ?? 0);
        }

        totalMonthProfit += total * commissionRate;
      }
    }
  }

  // ------------------------------------------------------------------
  // 💵 Profit per order (based on daily activation)
  // ------------------------------------------------------------------
  double getOrderProfit(OrderModel order) {
    final date =
    DateTime.fromMillisecondsSinceEpoch(order.createdAt ?? 0);

    final sameDayOrders = finishedOrders.where((o) {
      if (o == null) return false;

      final d = DateTime.fromMillisecondsSinceEpoch(o.createdAt ?? 0);

      return d.day == date.day &&
          d.month == date.month &&
          d.year == date.year;
    }).toList();

    // لو أقل من 3 في اليوم → صفر
    if (sameDayOrders.length < 3) return 0;

    return (order.totalOrder ?? 0) * commissionRate;
  }

  // ------------------------------------------------------------------
  Future<void> refreshOrders() async {
    await getOrders();
  }
}
