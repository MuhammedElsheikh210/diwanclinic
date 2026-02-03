import 'package:diwanclinic/Presentation/screens/sales/create_update/create_sales_view.dart';
import '../../../../../index/index_main.dart';

class SalesView extends StatefulWidget {
  final String? title;

  const SalesView({super.key, this.title});

  @override
  State<SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<SalesView> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GetBuilder<SalesViewModel>(
        init: SalesViewModel(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              title: Text(
                widget.title ?? "مندوبي المبيعات",
                style: context.typography.lgBold,
              ),
              elevation: 1,
              backgroundColor: AppColors.white,
            ),
            floatingActionButton: InkWell(
              onTap: () {
                Get.delete<CreateSalesViewModel>();
                showCustomBottomSheet(
                  context: context,
                  child: const CreateSalesView(),
                );
              },
              child: const Svgicon(icon: IconsConstants.fab_Button),
            ),
            body: controller.listSales == null
                ? const ShimmerLoader()
                : controller.listSales!.isEmpty
                ? const NoDataWidget()
                : ListView.builder(
              padding: EdgeInsets.symmetric(
                vertical: 15.h,
                horizontal: 5.w,
              ),
              itemCount: controller.listSales!.length,
              itemBuilder: (context, index) {
                final sales = controller.listSales![index];
                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 5.h,
                    horizontal: 10.w,
                  ),
                  child: SalesCard(
                    sales: sales ?? LocalUser(),
                    controller: controller,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
