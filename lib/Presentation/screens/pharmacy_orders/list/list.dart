import 'package:diwanclinic/Presentation/screens/pharmacy_orders/list/widget/PharmacyDailyReportWidget.dart';
import 'package:diwanclinic/Presentation/screens/pharmacy_orders/list/widget/app_bar.dart';

import '../../../../index/index_main.dart';

class PharmacyOrdersListScreen extends StatefulWidget {
  const PharmacyOrdersListScreen({super.key});

  @override
  State<PharmacyOrdersListScreen> createState() =>
      _PharmacyOrdersListScreenState();
}

class _PharmacyOrdersListScreenState
    extends State<PharmacyOrdersListScreen> {

  late final PharmacyOrdersListViewModel vm;

  // ============================================================
  // 🚀 INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    /// ✅ prevent duplicate controllers
    if (Get.isRegistered<PharmacyOrdersListViewModel>()) {

      vm = Get.find<PharmacyOrdersListViewModel>();

    } else {

      vm = Get.put(
        PharmacyOrdersListViewModel(),
      );
    }
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  @override
  void dispose() {

    /// ❌ مهم جدًا
    /// لو الشاشة temporary
    /// امسح الـ controller

    if (Get.isRegistered<PharmacyOrdersListViewModel>()) {
      Get.delete<PharmacyOrdersListViewModel>();
    }

    super.dispose();
  }

  // ============================================================
  // 🎨 UI
  // ============================================================

  @override
  Widget build(BuildContext context) {

    return GetBuilder<PharmacyOrdersListViewModel>(
      builder: (_) {

        return Scaffold(
          backgroundColor: AppColors.white,

          appBar: PharmacyOrdersDateAppBar(
            controller: vm,
          ),

          body: RefreshIndicator(
            color: AppColors.primary,

            onRefresh: vm.refreshAll,

            child: Column(
              children: [

                PharmacyDailyReportWidget(
                  controller: vm,
                ),

                Expanded(
                  child: PharmacyOrdersListBody(
                    vm: vm,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}