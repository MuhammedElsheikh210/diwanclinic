import 'package:diwanclinic/Presentation/screens/patient_orders/list/widget/order_list_body.dart';
import '../../../../index/index_main.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen>
    with SingleTickerProviderStateMixin {

  late OrdersListViewModel vm;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    vm = Get.put(OrdersListViewModel());
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const HomePatientAppBar(),
      body: Column(
        children: [

          _buildTabs(),

          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                OrdersListBody(vm: vm, type: OrderTabType.active),
                OrdersListBody(vm: vm, type: OrderTabType.finished),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Obx(() {
      return Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
        height: 50.h,
        decoration: BoxDecoration(
          color: const Color(0xffE5E5E5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            _tabItem(
              title: "الحالية (${vm.activeOrders.length})",
              index: 0,
            ),
            _tabItem(
              title: "المنتهية (${vm.finishedOrders.length})",
              index: 1,
            ),
          ],
        ),
      );
    });
  }

  Widget _tabItem({required String title, required int index}) {
    final bool isSelected = tabController.index == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          tabController.animateTo(index);
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
