import 'package:diwanclinic/Presentation/screens/patient_orders/list/controller.dart';
import 'package:diwanclinic/Presentation/screens/patient_orders/list/widget/order_list_body.dart';
import '../../../../index/index_main.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  late OrdersListViewModel vm;

  @override
  void initState() {
    super.initState();

    // ✅ Put ViewModel once
    vm = Get.put(OrdersListViewModel());

    // ❌ NO fetchOrders here
    // Realtime listener is started inside onInit()
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: const HomePatientAppBar(),

        // UI listens to realtime changes automatically
        body: OrdersListBody(vm: vm),
      ),
    );
  }
}
